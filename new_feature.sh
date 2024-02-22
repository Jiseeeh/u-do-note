#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <feature_name>"
  exit 1
fi

FEATURE_NAME=$1
FEATURE_DIR="lib/features/$FEATURE_NAME"

# Create the feature directory
mkdir -p "$FEATURE_DIR/data/datasources"
touch "$FEATURE_DIR/data/datasources/.gitkeep"
mkdir -p "$FEATURE_DIR/data/models"
touch "$FEATURE_DIR/data/models/.gitkeep"
mkdir -p "$FEATURE_DIR/data/repositories"
touch "$FEATURE_DIR/data/repositories/.gitkeep"
mkdir -p "$FEATURE_DIR/domain/entities"
touch "$FEATURE_DIR/domain/entities/.gitkeep"
mkdir -p "$FEATURE_DIR/domain/repositories"
touch "$FEATURE_DIR/domain/repositories/.gitkeep"
mkdir -p "$FEATURE_DIR/domain/usecases"
touch "$FEATURE_DIR/domain/usecases/.gitkeep"
mkdir -p "$FEATURE_DIR/presentation/pages"
touch "$FEATURE_DIR/presentation/pages/.gitkeep"
mkdir -p "$FEATURE_DIR/presentation/providers"
touch "$FEATURE_DIR/presentation/providers/.gitkeep"
mkdir -p "$FEATURE_DIR/presentation/widgets"
touch "$FEATURE_DIR/presentation/widgets/.gitkeep"

echo "Feature structure created for $FEATURE_NAME with .gitkeep files."
