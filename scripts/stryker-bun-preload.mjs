// Preloaded into the Stryker process when it runs under Bun (see the
// "test:mutation" script). Stryker's instrumenter loads @babel/core, which
// replaces Error.prepareStackTrace with a wrapper that forwards to Bun's
// native default. Bun's default throws "First argument must be an Error
// object" for the non-Error prototypes Vite builds at import time, so the
// @stryker-mutator/vitest-runner plugin fails to load. Babel's wrapper only
// rewrites stack frames for display, so ignoring the assignment is safe.
const original = Error.prepareStackTrace;
Object.defineProperty(Error, "prepareStackTrace", {
  configurable: true,
  get: () => original,
  set: () => {},
});
