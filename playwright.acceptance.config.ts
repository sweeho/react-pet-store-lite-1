import { defineConfig } from "@playwright/test";

import base from "./playwright.config";

// The locked acceptance suite's browser specs
// (tests/acceptance/<capability>/e2e/*.spec.ts), run only by
// `bun run test:acceptance:e2e`. Server, port and project come from
// playwright.config.ts.
export default defineConfig({
  ...base,
  testDir: "./tests/acceptance",
  testMatch: "**/e2e/**/*.spec.ts",
  // The merge gate reads this run on every Build ticket, and a sign-in plus
  // checkout flow takes several seconds on a CI runner. Shorter waits failed
  // working flows by timeout, so keep these floors even though the red suite
  // then runs longer.
  timeout: 15000,
  expect: { timeout: 5000 },
  // The merge gate reads one run; a retry would hide an unreliable test.
  retries: 0,
  // In CI the JUnit report is what the merge gate reads
  // (.vortex/config.yaml testEvidence.acceptance).
  reporter: process.env.CI
    ? [["list"], ["junit", { outputFile: ".vortex-results/acceptance/e2e-junit.xml" }]]
    : "list",
  use: {
    ...base.use,
    // An agent container's small /dev/shm hangs Chromium.
    launchOptions: { args: ["--disable-dev-shm-usage"] },
  },
});
