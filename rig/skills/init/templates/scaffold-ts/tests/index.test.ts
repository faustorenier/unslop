import { expect, it } from "vitest";
import * as entry from "../src/index.js";

it("loads the entry point", () => {
  expect(entry).toBeDefined();
});
