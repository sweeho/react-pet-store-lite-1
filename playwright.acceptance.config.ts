import { defineConfig, devices } from "@playwright/test";

// Browser specs of the locked acceptance suite (tests/acceptance/<capability>/e2e/),
// run only by `bun run test:acceptance:e2e`. Same server as playwright.config.ts.
const PORT = 5178;

export default defineConfig({
  testDir: "./tests/acceptance",
  testMatch: "**/e2e/**/*.spec.ts",
  globalSetup: "./e2e/global-setup.ts",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  // The merge gate reads one run; a retry would hide an unreliable test.
  retries: 0,
  // A flow that signs in and checks out takes several seconds on a CI runner;
  // shorter waits failed working flows by timeout. Keep these floors.
  timeout: 15000,
  expect: {
    timeout: 5000,
  },
  // Under CI the merge gate reads this JUnit report (testEvidence.acceptance).
  reporter: process.env.CI
    ? [["list"], ["junit", { outputFile: ".vortex-results/acceptance/e2e-junit.xml" }]]
    : "list",
  use: {
    baseURL: `http://localhost:${PORT}`,
    trace: "retain-on-failure",
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
    // See playwright.config.ts for why the vite bin file runs under `bun --bun`.
    command: `bun --bun ./node_modules/vite/bin/vite.js --port ${PORT} --strictPort`,
    url: `http://localhost:${PORT}`,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
    stdout: "pipe",
  },
});
