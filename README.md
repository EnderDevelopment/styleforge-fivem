# FiveM Clothing Editor Resource

StyleForge FiveM is an in-game clothing editor resource for FiveM servers. It provides a FiveM resource, NUI clothing editor, live outfit preview, male and female freemode model selection, reusable clothing presets, ACE permission control, and server-side persistent outfit storage without requiring external editing.

## Install

1. Copy the resource folder into your FiveM server's resources directory.
2. Add the resource to `server.cfg`:

   ```cfg
   ensure in_game_clothes_editor
   ```

3. Grant the editor ACE permission to the required group or player:

   ```cfg
   add_ace group.admin clothes.editor allow
   ```

4. Start or restart the resource.
5. Confirm that the resource can write its data files. It creates and maintains `presets.json` and `player_outfits.json` inside the resource folder.

The default resource folder name is `in_game_clothes_editor`. If you rename it, update the `ensure` line and the fallback resource name in `html/app.js` if required.

## Use

1. Join the server with an account that has the `clothes.editor` ACE permission.
2. Use the `/roupas` command in game.
3. Select the male or female freemode model.
4. Adjust component drawable values and prop values with the sliders.
5. Adjust texture values with the number fields. Changes are previewed immediately.
6. Enter a name and select `Save preset` to store a reusable server preset.
7. Select `Load` to apply a saved preset.
8. Select `Delete` to remove a saved preset.
9. Select `Save on character` to persist the current outfit for the player's license identifier.
10. Close the editor with the close button or the Escape key.

Configuration is available in `config.lua`. You can change the command, ACE permission, maximum number of presets, saved file names, automatic player outfit application, supported models, and clothing components.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/3497a523-3826-4b66-80cf-37555b2c956c?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=3497a523-3826-4b66-80cf-37555b2c956c
