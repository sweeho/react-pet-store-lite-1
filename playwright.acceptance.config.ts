import { defineConfig, devices } from "@playwright/test";

// The locked acceptance suite's browser specs
// (tests/acceptance/<capability>/e2e/), run only by
// `bun run test:acceptance:e2e`. Self-contained on purpose: it does not spread
// playwright.config.ts, so nothing there (e.g. its CI retries) leaks in.
const PORT = 5178;

export default defineConfig({
  // Per-test timeout. The merge gate reads this run on every Build ticket, and
  // a sign-in plus checkout flow takes several seconds on a CI runner. Shorter
  // waits failed working flows, so keep this floor even though the red suite
  // then runs longer.
  timeout: 15000,
  // The merge gate reads one run; a retry would hide an unreliable test.
  retries: 0,
  expect: {
    timeout: 5000,
  },
  testDir: "./tests/acceptance",
  testMatch: "**/e2e/**/*.spec.ts",
  globalSetup: "./e2e/global-setup.ts",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  // In CI the JUnit report is what the merge gate reads
  // (.vortex/config.yaml testEvidence.acceptance).
  reporter: process.env.CI
    ? [["list"], ["junit", { outputFile: ".vortex-results/acceptance/e2e-junit.xml" }]]
    : "list",
  use: {
    baseURL: `http://localhost:${PORT}`,
    // An agent container's small /dev/shm hangs Chromium.
    launchOptions: { args: ["--disable-dev-shm-usage"] },
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  webServer: {
    // Same server as playwright.config.ts: run Vite's bin under bun so
    // db/client.ts's bun:sqlite import resolves.
    command: `bun --bun ./node_modules/vite/bin/vite.js --port ${PORT} --strictPort`,
    url: `http://localhost:${PORT}`,
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
    stdout: "pipe",
  },
});
