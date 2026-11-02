import path from "path";
import AutoImport from "unplugin-auto-import/vite";
import { defineConfig } from "vitest/config";

import react from "@vitejs/plugin-react";

// The locked acceptance suite (tests/acceptance/**), run only by
// `bun run test:acceptance`. The default `bun run test` excludes it: it is
// written before the product code and stays red until the Build phase.
// Browser specs under tests/acceptance/<capability>/e2e/ belong to
// playwright.acceptance.config.ts, never to vitest.
// .tsx tests run in jsdom; .ts tests run in node, where db/client.ts's
// bun:sqlite import can resolve (see vitest.config.ts).
const exclude = ["node_modules", "tests/acceptance/**/e2e/**"];

export default defineConfig({
  plugins: [
    react(),
    AutoImport({
      imports: ["react", "react-router"],
      dts: "./auto-imports.d.ts",
    }),
  ],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  test: {
    projects: [
      {
        extends: true,
        test: {
          name: "acceptance-ui",
          environment: "jsdom",
          setupFiles: ["./src/test/setup.ts"],
          css: false,
          include: ["tests/acceptance/**/*.test.tsx"],
          exclude,
        },
      },
      {
        extends: true,
        test: {
          name: "acceptance",
          environment: "node",
          include: ["tests/acceptance/**/*.test.ts"],
          exclude,
        },
      },
    ],
  },
});
