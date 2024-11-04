# Ashrael-Package

The **Ashrael-Package** is a comprehensive suite of modules designed to enhance the **Avatar MUD** experience (avatar.outland.org:3000) by providing additional commands, automation features, and quality-of-life improvements. This package is built for players who want to streamline gameplay, manage multiple characters effortlessly, and maintain optimal resource management.

## Features

### 1. **Adventure Mode**
   - Toggle between **solo** and **group** play modes to adjust engagement levels based on your play style.
   - Manages recovery for health and mana, with built-in spell-ups and healing requests as needed.
   - **Status Checks:** Quickly view the current adventure mode status, recovery mode, and configuration.

### 2. **VoidWalker** (Beta)
   - **Voidwalking Between Characters:** Allows seamless switching between alts with thematic, immersive messages.
   - **Character Status Tracking:** Automatically stores each character’s basic stats (health, mana, inventory) and last room visited.
   - **Voidgaze Command:** Provides an overview of all characters’ statuses, locations, and a unique void-themed message.
   - **Item Search Across Characters:** Quickly locate items in the inventories of all your characters.
   - **Autologin Animation:** An immersive “slipping through the void” animation hides login screens.
   - **Custom Login/Logout Messaging:** Transition messages add depth with phrases like “You slip into the void…”

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
   - **Suppressing Login Screens**: Further refine VoidWalker’s ability to hide login screens, maintaining immersion with its “voidwalking” theme.
   - **Improved Character Management**: Streamline the management of multiple characters, including more intuitive adding, removing, and switching functionality.
   - **Local Persistence**: Implement local data storage to retain character stats, inventory, and status across sessions, enhancing efficiency and consistency without needing external files.

2. **Adventure Mode Generalization**:
   - **Expanded Class Support**: Broaden support across additional classes, allowing Adventure Mode to dynamically adapt spell-ups, healing, and recovery processes based on the character’s class and alignment.
   - **Generic Play Modes**: Refine solo and group play mode behaviors for more flexibility and situational adjustments, with customized options for different class needs and play styles.
   - **Enhanced Automation**: Build out the automation layer to better manage buffing, recovery, and engagement for both solo and group modes.

3. **PackageManager Maintenance**:
   - Continue refining version control and compatibility checks to ensure a stable experience across Mudlet updates, with a focus on seamless PackageManager functionality.

## Contributing

Contributions are welcome. For feature requests or bug reports, please submit an issue on the repository, or reach out to the project maintainer directly.

---

This package simplifies multi-character management, automated updates, and adventure mode controls, all while creating an immersive, customizable experience on Avatar MUD.
