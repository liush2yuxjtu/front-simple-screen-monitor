#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { basename } from "node:path";

const EXIT = {
  ship: 0,
  "re-cut": 1,
  rewrite: 2,
  invalid: 3,
  usage: 64,
};

const REQUIRED_PROOF_SHOTS = [
  {
    id: "screen_observation",
    label: "Screen observation",
    aliases: ["screen observation", "screen context", "current activity", "mock screen context"],
  },
  {
    id: "permission_request",
    label: "Permission request",
    aliases: ["permission request", "prompt appearing", "dynamic island prompt", "ask before it acts"],
  },
  {
    id: "allow",
    label: "ALLOW right swipe and green confirmation",
    aliases: ["allow", "right swipe", "green confirmation", "allowed count"],
  },
  {
    id: "block",
    label: "BLOCK left swipe and red denial",
    aliases: ["block", "left swipe", "red denial", "blocked count"],
  },
  {
    id: "trust_log",
    label: "Trust log or stats/history",
    aliases: ["trust log", "stats", "history", "remembered", "decision log"],
  },
  {
    id: "risk_clarity",
    label: "Risk clarity / high-risk example",
    aliases: ["risk clarity", "high-risk", "terminal command", "private message", "dangerous"],
  },
  {
    id: "recovery",
    label: "Recovery to the next request",
    aliases: ["recovery", "next request", "not stuck", "returning to the next request"],
  },
];

const SCORE_ITEMS = [
  {
    id: "problem_understood_15s",
    label: "Problem understood within 15 seconds",
    aliases: ["problem_understood_15s", "problem understood within 15 seconds", "15-second test", "first 15 seconds", "problem"],
  },
  {
    id: "allow_block_clear",
    label: "ALLOW/BLOCK interaction is clear",
    aliases: ["allow_block_clear", "allow/block interaction is clear", "allow block", "interaction clear", "right means allow", "left means block"],
  },
  {
    id: "permission_layer_clear",
    label: "Need for an AI permission layer is clear",
    aliases: ["permission_layer_clear", "need for an ai permission layer is clear", "permission layer", "ask before it acts"],
  },
  {
    id: "visual_memorable",
    label: "Visual direction is memorable",
    aliases: ["visual_memorable", "visual direction is memorable", "visual memorable", "memorable"],
  },
  {
    id: "feedback_obvious",
    label: "Decision feedback is obvious",
    aliases: ["feedback_obvious", "decision feedback is obvious", "feedback obvious", "decision feedback"],
  },
  {
    id: "viewer_can_explain",
    label: "Viewer knows how to try or explain it afterward",
    aliases: ["viewer_can_explain", "viewer knows how to try or explain it afterward", "try or explain", "stranger retell", "explain afterward"],
  },
];

const HELP = `
Usage:
  node scripts/${basename(process.argv[1] || "video-feature-self-verify.mjs")} [--strict] [--json] <evidence.json>

Reads a JSON evidence file for the 60-second video review and returns the
final merge format from docs/video-feature-self-verify.md and
docs/video-verify-subagents.md.

Options:
  --help      Show this help text.
  --strict    Treat missing timestamps, proof shots, score evidence, pacing,
              retell, and verdict mismatches as blocking validation issues.
  --json      Output structured JSON instead of the text final merge format.

Expected evidence can be flexible, but should include:
  - timestamped evidence notes or agent outputs
  - proofShots / requiredProofShots for the seven required proof shots
  - six 0-2 score items, plus timestamp evidence for each score
  - optional stateChanges / timeline / pacingMap
  - optional shotToUserValue map, ordered tasks, and stranger retell

Exit codes:
  0  ship
  1  re-cut
  2  rewrite
  3  invalid or unscorable input
  64 usage error
`.trim();

function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    console.log(HELP);
    process.exit(0);
  }

  if (args.error) {
    console.error(args.error);
    console.error(`Run with --help for usage.`);
    process.exit(EXIT.usage);
  }

  let input;
  try {
    input = JSON.parse(readFileSync(args.file, "utf8"));
  } catch (error) {
    writeInvalid(args, `Could not read or parse JSON: ${error.message}`);
    process.exit(EXIT.invalid);
  }

  const result = evaluateEvidence(input, args);

  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(renderFinalMerge(result));
  }

  process.exit(result.exitCode);
}

function parseArgs(argv) {
  const args = {
    strict: false,
    json: false,
    help: false,
    file: null,
  };

  for (const arg of argv) {
    if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else if (arg === "--strict") {
      args.strict = true;
    } else if (arg === "--json") {
      args.json = true;
    } else if (arg.startsWith("-")) {
      return { ...args, error: `Unknown option: ${arg}` };
    } else if (!args.file) {
      args.file = arg;
    } else {
      return { ...args, error: `Unexpected argument: ${arg}` };
    }
  }

  if (!args.help && !args.file) {
    return { ...args, error: "Missing evidence JSON file." };
  }

  return args;
}

function writeInvalid(args, message) {
  if (args.json) {
    console.log(JSON.stringify({ ok: false, error: message, exitCode: EXIT.invalid }, null, 2));
  } else {
    console.error(message);
  }
}

function evaluateEvidence(input, args) {
  const records = flattenRecords(input);
  const validation = [];
  const timestampedEvidence = collectTimestampedEvidence(input, records, validation);
  const proofShots = collectProofShots(input, records, validation);
  const scoring = collectScores(input, records, validation);
  const pacing = collectPacing(input, records, validation);
  const shotToUserValue = collectShotToUserValue(input, proofShots);
  const strangerRetell = collectStrangerRetell(input, validation);
  const declaredVerdict = normalizeVerdict(pick(input, ["verdict", "finalVerdict", "final_verdict", "decision"]));
  const thresholdVerdict = scoring.valid ? verdictForScore(scoring.total) : "invalid";
  const thresholdLabel = scoring.valid ? thresholdText(scoring.total) : "invalid or unscorable input";

  if (!scoring.valid) {
    validation.push(error("score", "Score must be six 0-2 items or a valid total from 0-12."));
  }

  if (declaredVerdict && scoring.valid && declaredVerdict !== thresholdVerdict) {
    validation.push(warning("verdict", `Declared verdict '${declaredVerdict}' does not match score threshold '${thresholdVerdict}'.`));
  }

  if (args.strict) {
    applyStrictRules(validation, {
      timestampedEvidence,
      proofShots,
      scoring,
      pacing,
      strangerRetell,
      thresholdVerdict,
    });
  }

  const blockingIssues = validation.filter((item) => item.level === "error");
  const effectiveVerdict = effectiveVerdictFor({
    thresholdVerdict,
    scoring,
    strict: args.strict,
    blockingIssues,
  });

  return {
    ok: blockingIssues.length === 0 && effectiveVerdict === "ship",
    strict: args.strict,
    verdict: effectiveVerdict,
    thresholdVerdict,
    thresholdLabel,
    score: scoring.total,
    scoreItems: scoring.items,
    timestampedEvidence,
    requiredProofShots: proofShots.items,
    missingProofShots: proofShots.missing,
    shotToUserValue,
    orderedTasks: collectOrderedTasks(input, proofShots.missing, validation),
    strangerRetell,
    pacing,
    validation,
    exitCode: effectiveVerdict === "invalid" ? EXIT.invalid : EXIT[effectiveVerdict],
  };
}

function applyStrictRules(validation, context) {
  if (context.timestampedEvidence.length === 0) {
    validation.push(error("timestamped evidence", "No timestamped evidence table was found."));
  }

  for (const shot of context.proofShots.items) {
    if (!shot.found) {
      validation.push(error("proof shots", `${shot.label} is missing.`));
    } else if (!shot.timestampValid) {
      validation.push(error("proof shots", `${shot.label} lacks a valid 0-60s timestamp.`));
    } else if (shot.verdict !== "pass") {
      validation.push(error("proof shots", `${shot.label} is not marked pass.`));
    }
  }

  for (const item of context.scoring.items) {
    if (!item.found) {
      validation.push(error("score", `${item.label} score is missing.`));
    } else if (!item.valid) {
      validation.push(error("score", `${item.label} must be scored 0, 1, or 2.`));
    } else if (!item.timestampValid) {
      validation.push(error("score", `${item.label} lacks timestamp evidence.`));
    }
  }

  if (!context.pacing.found) {
    validation.push(error("pacing", "No state-change pacing map was found."));
  } else if (context.pacing.gapsOverEightSeconds.length > 0) {
    validation.push(error("pacing", "State-change pacing has gaps over 8 seconds."));
  }

  if (!context.strangerRetell) {
    validation.push(error("stranger retell", "Missing one-line stranger retell."));
  }
}

function effectiveVerdictFor({ thresholdVerdict, scoring, strict, blockingIssues }) {
  if (!scoring.valid || thresholdVerdict === "invalid") {
    return "invalid";
  }

  if (!strict || blockingIssues.length === 0) {
    return thresholdVerdict;
  }

  return thresholdVerdict === "rewrite" ? "rewrite" : "re-cut";
}

function collectTimestampedEvidence(input, records, validation) {
  const explicit = firstArrayLike(input, [
    "timestampedEvidence",
    "timestamped_evidence",
    "timestampedEvidenceTable",
    "timestamped_evidence_table",
    "evidence",
    "notes",
    "agentOutputs",
    "subagents",
  ]);
  const sourceRecords = collectionHasItems(explicit) ? flattenRecords(explicit) : records;
  const evidence = [];

  for (const record of sourceRecords) {
    if (!isEvidenceLike(record.value)) continue;

    const timestamp = timestampInfo(record.value);
    const verdict = normalizeVerdict(extractField(record.value, ["verdict", "status", "result", "pass"]));
    const hasEvidenceBody = hasAnyKey(record.value, ["evidence", "note", "description", "fix", "check", "shot", "score", "timestamp", "time"]);

    if ((verdict === "pass" || verdict === "partial" || verdict === "fail") && !timestamp.valid) {
      validation.push(warning("timestamped evidence", `${record.path} has '${verdict}' without a valid timestamp.`));
    }

    if (timestamp.raw !== null || hasEvidenceBody) {
      evidence.push({
        timestamp: timestamp.display,
        timestampValid: timestamp.valid,
        area: stringify(extractField(record.value, ["agent", "area", "check", "shot", "item", "name", "title"])) || record.path,
        verdict: verdict || "note",
        evidence: stringify(extractField(record.value, ["evidence", "note", "description", "summary", "takeaway", "fix"])) || shortJson(record.value),
      });
    }
  }

  return dedupeEvidence(evidence).slice(0, 80);
}

function collectProofShots(input, records, validation) {
  const sources = firstArrayLike(input, ["proofShots", "proof_shots", "requiredProofShots", "required_proof_shots", "shots"]);
  const proofRecords = collectionHasItems(sources) ? normalizeEntries(sources) : normalizeEntries(records.map((record) => record.value));
  const items = [];

  for (const required of REQUIRED_PROOF_SHOTS) {
    const match = proofRecords.find((record) => aliasesMatch(record.label, required.aliases));
    const timestamp = timestampInfo(match?.value);
    const verdict = normalizeVerdict(extractField(match?.value, ["verdict", "status", "result", "pass"])) || (match ? "unknown" : "missing");
    const found = Boolean(match);
    const item = {
      id: required.id,
      label: required.label,
      found,
      timestamp: timestamp.display,
      timestampValid: timestamp.valid,
      verdict,
      fix: found ? stringify(extractField(match.value, ["fix", "recommendation", "pickup", "task"])) : "Add this proof shot before final cut.",
      evidence: found ? stringify(extractField(match.value, ["evidence", "note", "description", "summary"])) || shortJson(match.value) : "",
      userValue: found ? stringify(extractField(match.value, ["userValue", "user_value", "outcome", "value"])) : "",
    };
    items.push(item);
  }

  const missing = items
    .filter((item) => !item.found || !item.timestampValid || item.verdict === "fail" || item.verdict === "partial")
    .map((item) => ({
      shot: item.label,
      reason: !item.found
        ? "missing"
        : !item.timestampValid
          ? "missing valid timestamp"
          : `verdict is ${item.verdict}`,
      fix: item.fix,
    }));

  if (missing.length > 0) {
    validation.push(warning("proof shots", `${missing.length} required proof shot(s) are missing, partial, failed, or untimestamped.`));
  }

  return { items, missing };
}

function collectScores(input, records, validation) {
  const sources = firstArrayLike(input, ["scores", "scoreItems", "score_items", "perItemScores", "per_item_scores"]);
  const scoreRecords = collectionHasItems(sources) ? normalizeEntries(sources) : normalizeEntries(records.map((record) => record.value));
  const items = [];

  for (const scoreItem of SCORE_ITEMS) {
    const match = scoreRecords.find((record) => aliasesMatch(record.label, scoreItem.aliases));
    const rawScore = match ? extractScore(match.value) : null;
    const score = Number(rawScore);
    const timestamp = match && match.value && typeof match.value === "object"
      ? timestampInfo(match.value)
      : missingTimestamp();
    const hasScore = rawScore !== null && rawScore !== undefined && rawScore !== "";
    const valid = hasScore && Number.isInteger(score) && score >= 0 && score <= 2;
    items.push({
      id: scoreItem.id,
      label: scoreItem.label,
      found: Boolean(match),
      score: valid ? score : null,
      valid,
      timestamp: timestamp.display,
      timestampValid: timestamp.valid,
      evidence: match ? stringify(extractField(match.value, ["evidence", "note", "description", "reason", "timestampEvidence"])) || shortJson(match.value) : "",
    });
  }

  const complete = items.every((item) => item.found && item.valid);
  const totalFromItems = items.reduce((sum, item) => sum + (item.score ?? 0), 0);
  const rawTotal = pick(input, ["totalScore", "total_score", "score"]);
  const totalFromInput = Number(rawTotal);
  const hasValidInputTotal = Number.isInteger(totalFromInput) && totalFromInput >= 0 && totalFromInput <= 12;
  const total = complete ? totalFromItems : hasValidInputTotal ? totalFromInput : null;
  const valid = total !== null && total >= 0 && total <= 12;

  if (!complete && !hasValidInputTotal) {
    validation.push(warning("score", "Missing complete six-item 0-2 scoring and no valid total score was found."));
  }

  return { items, total, valid, complete };
}

function collectPacing(input, records) {
  const source = firstArrayLike(input, ["stateChanges", "state_changes", "timeline", "pacingMap", "pacing_map"]);
  const candidates = collectionHasItems(source) ? normalizeEntries(source) : normalizeEntries(records.map((record) => record.value))
    .filter((record) => aliasesMatch(record.label, ["state change", "pacing", "timeline"]));
  const points = [];

  for (const candidate of candidates) {
    const timestamp = timestampInfo(candidate.value);
    if (timestamp.valid) {
      points.push({
        seconds: timestamp.seconds[0],
        timestamp: timestamp.display,
        change: stringify(extractField(candidate.value, ["change", "state", "note", "description", "event"])) || candidate.label,
      });
    }
  }

  points.sort((a, b) => a.seconds - b.seconds);

  const gapsOverEightSeconds = [];
  for (let index = 1; index < points.length; index += 1) {
    const gap = points[index].seconds - points[index - 1].seconds;
    if (gap > 8) {
      gapsOverEightSeconds.push({
        from: points[index - 1].timestamp,
        to: points[index].timestamp,
        gap,
      });
    }
  }

  return {
    found: points.length > 0,
    points,
    gapsOverEightSeconds,
  };
}

function collectShotToUserValue(input, proofShots) {
  const source = firstArrayLike(input, ["shotToUserValue", "shot_to_user_value", "userValueMap", "user_value_map"]);
  const entries = normalizeEntries(source);
  const map = [];

  for (const entry of entries) {
    map.push({
      shot: entry.label,
      userValue: stringify(extractField(entry.value, ["userValue", "user_value", "outcome", "value", "why"])) || stringify(entry.value),
      timestamp: timestampInfo(entry.value).display,
    });
  }

  if (map.length > 0) return map;

  return proofShots.items
    .filter((shot) => shot.found)
    .map((shot) => ({
      shot: shot.label,
      userValue: shot.userValue || inferUserValue(shot.id),
      timestamp: shot.timestamp,
    }));
}

function collectStrangerRetell(input, validation) {
  const retell = stringify(pick(input, [
    "strangerRetell",
    "stranger_retell",
    "predictedRetell",
    "predicted_retell",
    "retell",
  ]));

  if (!retell) {
    validation.push(warning("stranger retell", "Missing one-line stranger retell."));
  }

  return retell;
}

function collectOrderedTasks(input, missingProofShots, validation) {
  const source = firstArrayLike(input, [
    "orderedTasks",
    "ordered_tasks",
    "recutTasks",
    "re_cut_tasks",
    "rewriteTasks",
    "rewrite_tasks",
    "tasks",
    "pickupShots",
    "pickup_shots",
  ]);
  const tasks = Array.isArray(source)
    ? source.map((task, index) => stringify(task) || `Task ${index + 1}`)
    : normalizeEntries(source).map((entry) => stringify(entry.value) || entry.label);

  if (tasks.length > 0) return tasks;

  const derived = [
    ...missingProofShots.map((shot) => `${shot.fix || "Add proof shot"} (${shot.shot}).`),
    ...validation
      .filter((item) => item.level === "error" || item.level === "warning")
      .slice(0, 5)
      .map((item) => `Fix ${item.area}: ${item.message}`),
  ];

  return [...new Set(derived)].slice(0, 8);
}

function renderFinalMerge(result) {
  const lines = [];
  lines.push(`1. Ship/re-cut/rewrite verdict: ${result.verdict}`);
  lines.push(`   Threshold verdict: ${result.thresholdVerdict} (${result.thresholdLabel})`);
  lines.push(`2. 0-12 score: ${result.score ?? "invalid"}/12`);
  lines.push("");
  lines.push("3. Timestamped evidence table:");
  lines.push("   | timestamp | area | verdict | evidence |");
  lines.push("   | --- | --- | --- | --- |");
  for (const row of nonEmpty(result.timestampedEvidence, [{
    timestamp: "missing",
    area: "timestamped evidence",
    verdict: "fail",
    evidence: "No timestamped evidence was found.",
  }])) {
    lines.push(`   | ${cell(row.timestamp)} | ${cell(row.area)} | ${cell(row.verdict)} | ${cell(row.evidence)} |`);
  }
  lines.push("");
  lines.push("4. Missing proof shots:");
  if (result.missingProofShots.length === 0) {
    lines.push("   - none");
  } else {
    for (const shot of result.missingProofShots) {
      const fix = shot.fix ? ` ${shot.fix}` : "";
      lines.push(`   - ${shot.shot}: ${shot.reason}.${fix}`);
    }
  }
  lines.push("");
  lines.push("5. Shot-to-user-value map:");
  if (result.shotToUserValue.length === 0) {
    lines.push("   - missing");
  } else {
    for (const row of result.shotToUserValue) {
      lines.push(`   - ${row.timestamp || "untimestamped"} ${row.shot}: ${row.userValue}`);
    }
  }
  lines.push("");
  lines.push("6. Ordered re-cut or rewrite tasks:");
  if (result.orderedTasks.length === 0) {
    lines.push("   - none");
  } else {
    result.orderedTasks.forEach((task, index) => {
      lines.push(`   ${index + 1}. ${task}`);
    });
  }
  lines.push("");
  lines.push(`7. One-line stranger retell: ${result.strangerRetell || "missing"}`);

  if (result.validation.length > 0) {
    lines.push("");
    lines.push("Validation:");
    for (const item of result.validation) {
      lines.push(`   - ${item.level}: ${item.area}: ${item.message}`);
    }
  }

  return lines.join("\n");
}

function verdictForScore(score) {
  if (!Number.isInteger(score) || score < 0 || score > 12) return "invalid";
  if (score >= 9) return "ship";
  if (score >= 7) return "re-cut";
  return "rewrite";
}

function thresholdText(score) {
  if (score >= 9) return "9-12: ship the video";
  if (score >= 7) return "7-8: re-cut the video";
  if (score >= 5) return "5-6: rewrite the script";
  return "0-4: fix the narrative before implementation";
}

function flattenRecords(value, path = "$", out = []) {
  if (!value || typeof value !== "object") return out;
  if (Array.isArray(value)) {
    value.forEach((item, index) => flattenRecords(item, `${path}[${index}]`, out));
    return out;
  }
  out.push({ value, path });
  for (const [key, child] of Object.entries(value)) {
    if (child && typeof child === "object") {
      flattenRecords(child, `${path}.${key}`, out);
    }
  }
  return out;
}

function normalizeEntries(value) {
  if (!value) return [];
  if (Array.isArray(value)) {
    return value.map((item, index) => ({
      label: labelFor(item, String(index)),
      value: item,
    }));
  }
  if (typeof value === "object") {
    return Object.entries(value).map(([key, item]) => ({
      label: labelFor(item, key),
      value: item,
    }));
  }
  return [];
}

function firstArrayLike(input, keys) {
  for (const key of keys) {
    const value = pick(input, [key]);
    if (!value) continue;
    if (Array.isArray(value)) return value;
    if (typeof value === "object") return value;
  }
  return [];
}

function collectionHasItems(value) {
  if (Array.isArray(value)) return value.length > 0;
  if (value && typeof value === "object") return Object.keys(value).length > 0;
  return false;
}

function labelFor(value, fallback) {
  if (value && typeof value === "object") {
    return stringify(extractField(value, ["shot", "item", "check", "name", "title", "label", "agent", "area"])) || fallback;
  }
  return fallback;
}

function aliasesMatch(label, aliases) {
  const normalizedLabel = normalize(label);
  if (!normalizedLabel) return false;
  return aliases.some((alias) => {
    const normalizedAlias = normalize(alias);
    if (!normalizedAlias) return false;
    if (normalizedLabel.includes(normalizedAlias)) return true;
    return normalizedLabel.length >= 4 && normalizedAlias.length >= 4 && normalizedAlias.includes(normalizedLabel);
  });
}

function normalize(value) {
  return stringify(value).toLowerCase().replace(/[^a-z0-9]+/g, "");
}

function timestampInfo(value) {
  const raw = extractField(value, ["timestamp", "time", "at", "start", "range"]);
  if (raw === null || raw === undefined || raw === "") {
    return { raw: null, display: "missing", valid: false, seconds: [] };
  }

  const seconds = parseTimestamp(raw);
  return {
    raw,
    display: stringify(raw),
    valid: seconds.length > 0 && seconds.every((second) => second >= 0 && second <= 60),
    seconds,
  };
}

function missingTimestamp() {
  return { raw: null, display: "missing", valid: false, seconds: [] };
}

function parseTimestamp(value) {
  if (typeof value === "number" && Number.isFinite(value)) return [value];
  const text = stringify(value);
  if (!text) return [];

  const mmss = [...text.matchAll(/\b(?:(\d{1,2}):)?(\d{1,2})(?:\.(\d+))?\b/g)]
    .map((match) => {
      const minutes = match[1] ? Number(match[1]) : 0;
      const seconds = Number(match[2]);
      const fraction = match[3] ? Number(`0.${match[3]}`) : 0;
      return minutes * 60 + seconds + fraction;
    })
    .filter((second) => Number.isFinite(second));

  if (mmss.length > 0) return mmss;

  const seconds = [...text.matchAll(/\b(\d+(?:\.\d+)?)\s*s\b/gi)]
    .map((match) => Number(match[1]))
    .filter((second) => Number.isFinite(second));

  return seconds;
}

function extractField(value, keys) {
  if (value === null || value === undefined) return null;
  if (typeof value !== "object") return value;
  const wanted = new Set(keys.map(normalize));
  for (const [key, child] of Object.entries(value)) {
    if (wanted.has(normalize(key))) return child;
  }
  return null;
}

function pick(value, keys) {
  return extractField(value, keys);
}

function extractScore(value) {
  if (typeof value === "number") return value;
  return extractField(value, ["score", "points", "value"]);
}

function normalizeVerdict(value) {
  if (value === true) return "pass";
  if (value === false) return "fail";
  const text = stringify(value).toLowerCase().trim();
  if (!text) return "";
  if (["ship", "pass", "passed", "ok", "yes"].includes(text)) return text === "ship" ? "ship" : "pass";
  if (["partial", "mixed", "warning"].includes(text)) return "partial";
  if (["fail", "failed", "no", "missing"].includes(text)) return "fail";
  if (["re-cut", "recut", "re cut"].includes(text)) return "re-cut";
  if (["rewrite", "fix narrative", "narrative"].includes(text)) return "rewrite";
  return text;
}

function isEvidenceLike(value) {
  if (!value || typeof value !== "object") return false;
  return hasAnyKey(value, [
    "timestamp",
    "time",
    "verdict",
    "status",
    "result",
    "pass",
    "score",
    "shot",
    "check",
    "agent",
    "evidence",
    "note",
    "description",
  ]);
}

function hasAnyKey(value, keys) {
  if (!value || typeof value !== "object") return false;
  const available = new Set(Object.keys(value).map(normalize));
  return keys.some((key) => available.has(normalize(key)));
}

function stringify(value) {
  if (value === null || value === undefined) return "";
  if (typeof value === "string") return value;
  if (typeof value === "number" || typeof value === "boolean") return String(value);
  if (Array.isArray(value)) return value.map(stringify).filter(Boolean).join("; ");
  if (typeof value === "object") {
    const preferred = extractField(value, ["text", "message", "summary", "description", "note", "evidence", "value"]);
    if (preferred && preferred !== value) return stringify(preferred);
    return JSON.stringify(value);
  }
  return String(value);
}

function shortJson(value) {
  const text = stringify(value);
  return text.length > 160 ? `${text.slice(0, 157)}...` : text;
}

function cell(value) {
  return stringify(value).replace(/\|/g, "\\|").replace(/\n/g, " ");
}

function nonEmpty(value, fallback) {
  return value.length > 0 ? value : fallback;
}

function dedupeEvidence(rows) {
  const seen = new Set();
  return rows.filter((row) => {
    const key = `${row.timestamp}|${row.area}|${row.verdict}|${row.evidence}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function inferUserValue(id) {
  const values = {
    screen_observation: "Shows why AI action needs current screen context.",
    permission_request: "Makes consent visible before action.",
    allow: "Shows the user can approve a safe action quickly.",
    block: "Shows the user can stop risky action quickly.",
    trust_log: "Proves decisions are remembered and auditable.",
    risk_clarity: "Clarifies the danger the permission layer protects against.",
    recovery: "Shows the system continues instead of getting stuck.",
  };
  return values[id] || "Maps the shot to a user outcome.";
}

function warning(area, message) {
  return { level: "warning", area, message };
}

function error(area, message) {
  return { level: "error", area, message };
}

main();
