#!/bin/bash
#
# Compiles the button.js file for production use.
#
# Copyright 2012 25c. All Rights Reserved.

vendor/assets/closure-library/closure/bin/build/closurebuilder.py --root=vendor/assets/closure-library/ --root=app/assets/javascripts/button/ --namespace="_25c.Button" --output_mode=compiled --compiler_jar=vendor/assets/closure-library/compiler.jar --compiler_flags="--compilation_level=ADVANCED_OPTIMIZATIONS" > public/javascripts/button/button-compiled.js