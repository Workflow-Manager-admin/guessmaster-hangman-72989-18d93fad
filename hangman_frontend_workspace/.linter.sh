#!/bin/bash
cd /home/kavia/workspace/code-generation/guessmaster-hangman-72989-18d93fad/hangman_frontend_workspace/hangman_frontend
npx eslint 
$ESLINT_EXIT_CODE
npm run build
BUILD_EXIT_CODE=$?
if [ $ESLINT_EXIT_CODE -ne 0 ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
   exit 1
fi

