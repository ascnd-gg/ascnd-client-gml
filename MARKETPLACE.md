# GameMaker Marketplace Submission Guide

## Prerequisites

1. **YoYo Games Account** - Create one at https://accounts.yoyogames.com
2. **Publisher Account** - Apply at https://marketplace.yoyogames.com/become-a-publisher

## Creating the Package

### Step 1: Import the SDK into GameMaker

1. Create a new GameMaker project
2. Create a folder structure:
   - `Scripts/scr_ascnd/` - Copy `scr_ascnd.gml` here
3. Optional: Add the example as a demo room

### Step 2: Create an Extension (Alternative Method)

If you want to distribute as an extension instead of scripts:

1. Right-click Extensions > Create Extension
2. Name it "Ascnd"
3. Right-click the extension > Add File > GML
4. Copy the SDK code into the GML file
5. Define all functions in the extension properties

### Step 3: Export as Local Package

1. In GameMaker, go to **Tools > Create Local Package**
2. Select all Ascnd-related assets
3. Fill in package details:
   - **Name:** Ascnd Leaderboard SDK
   - **Publisher:** Ascnd
   - **Version:** 1.0.0
   - **Description:** Official SDK for Ascnd leaderboard API
4. Export as `.yymps` file

## Submitting to Marketplace

1. Go to https://marketplace.yoyogames.com/publishers
2. Click "Add Asset"
3. Fill in:
   - **Asset Type:** Extension
   - **Name:** Ascnd Leaderboard SDK
   - **Price:** Free
   - **Category:** Networking / Online Services
   - **Description:** (use content from README.md)
   - **Screenshots:** Add SDK integration examples
   - **Documentation URL:** https://docs.ascnd.gg
   - **Support URL:** https://github.com/ascnd-gg/ascnd-client-gml/issues
4. Upload the `.yymps` file
5. Submit for review

## Review Process

- YoYo Games reviews all submissions
- Typically takes 1-2 weeks
- They may request changes or clarifications
- Once approved, it appears on the Marketplace

## Updating the Asset

1. Create a new `.yymps` with updated code
2. Go to your Publisher dashboard
3. Click "Update" on the asset
4. Upload new package with version bump
5. Add changelog notes
6. Submit for review

## Tips

- Include clear documentation in the package
- Add example code showing basic usage
- Test on multiple platforms before submission
- Respond quickly to reviewer feedback
