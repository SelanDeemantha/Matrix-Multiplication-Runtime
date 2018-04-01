#!/bin/bash
echo "Generating pdf..."
cd results
pdflatex PDF.tex
echo "Written to PDF.pdf"
