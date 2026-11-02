import { defineConfig, mergeConfig } from "vitest/config";

import base from "./vitest.config";

// The locked acceptance suite (tests/acceptance/**), run only by
// `bun run test:acceptance`. The default `bun run test` excludes it, because it
// is red until the Build phase makes it pass. Browser specs under
// tests/acceptance/<capability>/e2e/ belong to playwright.acceptance.config.ts.
// Same split as vitest.config.ts: .tsx (UI) tests run in jsdom, .ts tests in
// node, where db/client.ts's `bun:sqlite` import can resolve.
const e2e = "tests/acceptance/**/e2e/**";

export default mergeConfig(
  { ...base, test: { ...base.test, projects: undefined } },
  defineConfig({
    test: {
      projects: [
        {
          extends: true,
          test: {
            name: "acceptance-client",
            environment: "jsdom",
            setupFiles: ["./src/test/setup.ts"],
            css: false,
            include: ["tests/acceptance/**/*.test.tsx"],
            exclude: [e2e],
          },
        },
        {
          extends: true,
          test: {
            name: "acceptance-server",
            environment: "node",
            include: ["tests/acceptance/**/*.test.ts"],
            exclude: [e2e],
          },
        },
      ],
    },
  }),
);
