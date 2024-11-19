#!/bin/sh
set -e # Exit on errors

yarn run build-backend
node apps/backend/src/scripts/preparePackageJson.js ./apps/backend/.medusa/server/package.json
cp apps/backend/medusa-config.js apps/backend/.medusa/server
cd apps/backend
yarn install
cd .medusa/server
touch yarn.lock
yarn install
yarn start --host=0.0.0.0 --port=9000
