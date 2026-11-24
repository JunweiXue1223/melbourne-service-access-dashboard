#!/usr/bin/env bash
# Download the ABS 2021 ASGS Edition 3 boundary files used by the project.
# They are too large to keep in git (the SAL shapefile alone is ~140 MB unzipped).
# Licence: CC BY 4.0, (c) Australian Bureau of Statistics.
set -euo pipefail

cd "$(dirname "$0")/../raw"
BASE="https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/access-and-downloads/digital-boundary-files"

for name in SAL_2021_AUST_GDA94_SHP SUA_2021_AUST_GDA94; do
  if [ -d "$name" ]; then
    echo "$name already present, skipping"
    continue
  fi
  echo "Downloading $name.zip ..."
  curl -fL --retry 3 -o "$name.zip" "$BASE/$name.zip"
  unzip -q -o "$name.zip" -d "$name"
  rm "$name.zip"
done

echo "Done. Shapefiles are in data/raw/ (ignored by git)."
