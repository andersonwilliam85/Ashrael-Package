# Ashrael-Package

The **Ashrael-Package** is a comprehensive suite of modules designed to enhance the **Avatar MUD** experience (avatar.outland.org:3000) by providing additional commands, automation features, and quality-of-life improvements. This package is built for players who want to streamline gameplay, manage multiple characters effortlessly, and maintain optimal resource management.

## Features

### 1. **VoidWalker**
   - **Voidwalking Between Characters:** Seamlessly switch between alts with immersive, void-themed messages.
   - **Character Status Tracking:** Automatically stores each character’s basic stats (health, mana, inventory) and last room visited.
   - **Local Persistence:** Stores character data locally, including stats and inventory, for greater reliability across sessions.
   - **Voidgaze Command:** Provides an overview of all characters’ statuses, locations, and a unique void-themed message.
   - **Item Search Across Characters:** Quickly locate items across all character inventories.
   - **Consolidated Inventory View:** Summarizes items across all characters, displaying each character’s possession with immersive messaging.
   - **Autologin Animation:** A “slipping through the void” animation hides login screens, adding to the experience.
   - **Custom Login/Logout Messaging:** Thematic transition messages add immersion, e.g., “You slip into the void…”

### 2. **Adventure Mode**
   - Toggle between **solo** and **group** play modes to adjust engagement levels based on your play style.
   - Manages recovery for health and mana, with built-in spell-ups and healing requests as needed.
   - **Status Checks:** Quickly view the current adventure mode status, recovery mode, and configuration.
   - **Note:** Adventure Mode currently has limited flexibility, supporting only a single-character configuration. Significant enhancements are planned to generalize functionality for a wider range of characters.

### 3. **PackageManager**
   - **Automated Update Check:** Easily check for available updates to keep your package up-to-date with the latest features and fixes.
   - **Version Management:** Choose to install the latest release or a specific version, with commands to list available versions and switch as needed.
   - **Version Control Commands:** 
     - **`ashpkg update`**: Checks for and installs the latest version.
     - **`ashpkg versions`**: Lists all available versions.
     - **`ashpkg switch <version>`**: Switches to a specified version if it meets the minimum support requirements.

## Installation

1. **Download the Latest Release**:
   - Visit the [latest releases page](https://github.com/andersonwilliam85/Ashrael-Package/releases).
   - Download the `Ashrael-Package.mpackage` file associated with the latest version.

2. **Install in Mudlet**:
   - Open Mudlet, go to **Package Manager**, and select **Install Package**.
   - Select the downloaded `Ashrael-Package.mpackage` file to complete the installation.

3. **Alternatively, Install Directly from the Command Line**:
   - Run the following command in your Mudlet command line to install the latest version directly:
     ```lua
     lua installPackage("https://github.com/andersonwilliam85/Ashrael-Package/releases/latest/download/Ashrael-Package.mpackage")
     ```

4. **Configure Settings**:
   - Set up any required aliases, triggers, or settings for **Adventure Mode** and **VoidWalker** as outlined in the documentation.

## Requirements

- **Mudlet** version 4.10+ for full feature compatibility.
- A valid Avatar MUD account.

## Roadmap

1. **VoidWalker Enhancements**:
   - **Advanced Character Management**: Streamline character registration and provide in-depth management for multi-character accounts. Additional configuration options by character level are also planned.
   - **Convergence**: A new feature that will enable automated gear swapping between alts, improving inventory management and preparation for voidwalking.

2. **Adventure Mode Generalization**:
   - **Expanded Class Support**: Broaden support across additional classes, adapting spell-ups, healing, and recovery based on character class and alignment.
   - **Generic Play Modes**: Generalize solo and group modes to accommodate diverse class and playstyle needs.
   - **Enhanced Automation**: Refine automation to manage buffs, recovery, and engagement efficiently for both solo and group play.

3. **PackageManager Refinements**:
   - Ensure seamless compatibility and stability with Mudlet updates, focusing on package update checks and version management.

## Contributing

Contributions are welcome. For feature requests or bug reports, please submit an issue on the repository, or reach out to the project maintainer directly.

---