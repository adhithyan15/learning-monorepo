const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const [packageName, targetPath = "."] = process.argv.slice(2);

if (!packageName) {
  console.error("❌ Please provide a package name.\nUsage: node create-ts-package.js <package-name> [target-path]");
  process.exit(1);
}

const packageDir = path.resolve(targetPath, packageName);
const srcDir = path.join(packageDir, "src");

const writeFile = (filePath, contents) => {
  fs.writeFileSync(filePath, contents + "\n", { encoding: "utf8" });
};

// Step 1: Create directories
fs.mkdirSync(packageDir, { recursive: true });
fs.mkdirSync(srcDir, { recursive: true });

// Step 2: Initialize package.json
execSync("npm init -y", { cwd: packageDir, stdio: "inherit" });

// Step 3: Install TypeScript
execSync("npm install --save-dev typescript", { cwd: packageDir, stdio: "inherit" });

// Step 4: Create tsconfig.json
writeFile(
  path.join(packageDir, "tsconfig.json"),
  JSON.stringify(
    {
      compilerOptions: {
        target: "ES2019",
        module: "ESNext",
        moduleResolution: "Node",
        declaration: true,
        outDir: "dist",
        rootDir: "src",
        strict: true,
        esModuleInterop: true,
        forceConsistentCasingInFileNames: true,
        skipLibCheck: true,
      },
      include: ["src"],
    },
    null,
    2
  )
);

// Step 5: Create example source file
writeFile(
  path.join(srcDir, "index.ts"),
  `export function greet(name: string): string {
  return \`Hello, \${name}!\`;
}`
);

// Step 6: Modify package.json
const pkgJsonPath = path.join(packageDir, "package.json");
const pkgJson = JSON.parse(fs.readFileSync(pkgJsonPath, "utf8"));

pkgJson.main = "dist/index.js";
pkgJson.types = "dist/index.d.ts";
pkgJson.scripts = {
  build: "tsc",
};
pkgJson.exports = {
  ".": {
    import: "./dist/index.js",
    require: "./dist/index.js",
  },
};

fs.writeFileSync(pkgJsonPath, JSON.stringify(pkgJson, null, 2));

// Step 7: Add .npmignore
writeFile(
  path.join(packageDir, ".npmignore"),
  `src/
tsconfig.json
*.log`
);

// Step 8: Add .gitignore
writeFile(
  path.join(packageDir, ".gitignore"),
  `node_modules/
dist/
*.log
.env
.DS_Store`
);

// Step 9: Add empty README.md
writeFile(path.join(packageDir, "README.md"), "");

console.log(`✅ Package '${packageName}' created successfully at '${packageDir}'.`);
console.log(`👉 To build it:`);
console.log(`   cd ${packageDir} && npm run build`);