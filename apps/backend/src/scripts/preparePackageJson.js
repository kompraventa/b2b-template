const fs = require("fs");
const path = require("path");

// Get the file path from command-line arguments
const filePath = process.argv[2];

if (!filePath) {
  console.error("Error: Please provide the path to the package.json file.");
  process.exit(1);
}

// Resolve the full path to the package.json file
const packageJsonPath = path.resolve(filePath);

// Check if the file exists
if (!fs.existsSync(packageJsonPath)) {
  console.error(`Error: File not found at "${packageJsonPath}".`);
  process.exit(1);
}

// Read package.json
let packageJson;
try {
  packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));
} catch (error) {
  console.error(`Error: Failed to parse JSON from "${packageJsonPath}".`);
  process.exit(1);
}

// Remove the "@starter/types" entry from dependencies or devDependencies
["dependencies", "devDependencies"].forEach((key) => {
  if (packageJson[key] && packageJson[key]["@starter/types"]) {
    delete packageJson[key]["@starter/types"];
  }
});

// Write the updated package.json back to the file
try {
  fs.writeFileSync(
    packageJsonPath,
    JSON.stringify(packageJson, null, 2) + "\n",
    "utf-8"
  );
  console.log(`Removed "@starter/types" from "${packageJsonPath}".`);
} catch (error) {
  console.error(`Error: Failed to write to "${packageJsonPath}".`);
  process.exit(1);
}
