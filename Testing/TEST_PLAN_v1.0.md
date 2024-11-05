### **Ashrael Package - Comprehensive Test Plan for External Commands**

#### **Test Plan Version**: 1.0  
#### **Date**: November 4, 2024  
#### **Scope**: Test all public commands and aliases for the Ashrael Package modules.

---

### **Testing Environment**

1. **Environment Setup**: Load the Ashrael package in Mudlet with an active connection to the Avatar MUD or another relevant MUD environment.
2. **Prerequisites**:
   - All GMCP configurations are active.
   - Characters are registered with the Voidwalker module.
   
---

### **Modules Covered**

1. **VoidWalker**
2. **Adventure Mode**
3. **PackageManager**
4. **Inventory Management**

---

### **Test Cases**

#### 1. **VoidWalker Module Commands**

   - **voidwalk register <password>**
     - **Steps**: Run `voidwalk register <password>` with a new character.
     - **Expected Outcome**: Character registers with VoidWalker, showing immersive messaging on successful registration and inventory initialization.

   - **voidwalk add <character> <password>**
     - **Steps**: Run `voidwalk add <character> <password>` after registering the current character.
     - **Expected Outcome**: Character is added with an immersive confirmation and inventory initialized.

   - **voidwalk remove <character>**
     - **Steps**: Run `voidwalk remove <character>` for an existing character.
     - **Expected Outcome**: Character is removed with confirmation and a void-themed message indicating removal from VoidWalker.

   - **voidwalk <character>**
     - **Steps**: Run `voidwalk <character_name>` to switch to the specified character.
     - **Expected Outcome**: Switches character, showing an immersive void-themed message and immediately updating stats and inventory upon login.

   - **voidgaze list**
     - **Steps**: Run `voidgaze list`.
     - **Expected Outcome**: Lists all registered characters with statuses and last known locations, using immersive void-inspired descriptions.

   - **voidgaze <character>**
     - **Steps**: Run `voidgaze <character_name>`.
     - **Expected Outcome**: Displays character details, including inventory and stats, with immersive narrative messaging.

   - **voidgaze inventory**
     - **Steps**: Run `voidgaze inventory`.
     - **Expected Outcome**: Shows a consolidated inventory across all characters, presenting items with an immersive, void-themed message.

   - **voidgaze search <item>**
     - **Steps**: Run `voidgaze search <item_name>`.
     - **Expected Outcome**: Searches all inventories for the specified item (fuzzy matching) and presents results with a void-themed narrative. If no item is found, an immersive message from the void indicates the absence.

#### 2. **Adventure Mode Commands**

   - **adv**
     - **Steps**: Run `adv`.
     - **Expected Outcome**: Toggles Adventure mode ON/OFF, confirming the change with status messaging.

   - **adv solo**
     - **Steps**: Run `adv solo`.
     - **Expected Outcome**: Sets Adventure mode to Solo mode with an in-game confirmation.

   - **adv group**
     - **Steps**: Run `adv group`.
     - **Expected Outcome**: Sets Adventure mode to Group mode with a confirmation message.

   - **adv resume**
     - **Steps**: Run `adv resume`.
     - **Expected Outcome**: Resumes Adventure mode from Recovery mode with appropriate messaging.

   - **adv recover**
     - **Steps**: Run `adv recover`.
     - **Expected Outcome**: Toggles Recovery mode if Adventure mode is active, with confirmation feedback.

   - **adv status**
     - **Steps**: Run `adv status`.
     - **Expected Outcome**: Shows the current status of Adventure and Recovery modes.

   - **adv reset**
     - **Steps**: Run `adv reset`.
     - **Expected Outcome**: Resets both Adventure and Recovery modes to OFF with a status confirmation.

#### 3. **PackageManager Commands**

   - **ashpkg update**
     - **Steps**: Run `ashpkg update`.
     - **Expected Outcome**: Checks for updates, downloading the latest version if available, and displays an in-game status message.

   - **ashpkg versions**
     - **Steps**: Run `ashpkg versions`.
     - **Expected Outcome**: Lists all available package versions in the user’s terminal.

   - **ashpkg switch <version>**
     - **Steps**: Run `ashpkg switch <version>`.
     - **Expected Outcome**: Switches to the specified version with confirmation and a prompt to reload.

#### 4. **Inventory Management Module Commands**

   - **inventory show**
     - **Steps**: Run `inventory show`.
     - **Expected Outcome**: Displays a consolidated list of items in all inventories, presenting an immersive message about each item’s presence in the void.

   - **inventory update**
     - **Steps**: Run `inventory update` with an active character.
     - **Expected Outcome**: Updates the inventory without data loss, displaying an immersive message indicating the void has refreshed its inventory.

---

### **Completion Criteria**

- All commands return expected results and immersive messages.
- No technical or debug information appears in user-facing outputs.
- All commands consistently handle multiple characters and maintain data integrity across switches.