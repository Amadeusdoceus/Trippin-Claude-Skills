# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

Trippin is **pre-MVP** — this repo currently contains only a product briefing (`briefing.md`, in Portuguese), no code. Read `briefing.md` first for full product context (personas, modules, data model, roadmap, risks) before proposing any implementation.

The "suggested stack" in `briefing.md` §6 (React Native/Expo, NestJS or Supabase, PostgreSQL, OCR+LLM extraction) is explicitly marked as unvalidated — confirm with the user before treating it as a decision.

## Architecture

Product is organized into four independent modules that share a trip as the central entity:
1. **User management** — admin/guest roles, invites, permissions
2. **Schedule/calendar** — day/week/month views anchored to real trip dates
3. **Expense splitter** — expenses tied to schedule events, split among participants
4. **Smart file reader** — OCR/LLM extraction from PDFs/screenshots/photos into events or expenses

## Conventions

- Product docs are written in Portuguese (pt-BR).

Re-run `/init` once actual code/scaffolding exists so this file can capture real build/test/lint commands and conventions.
