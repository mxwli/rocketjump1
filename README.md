# rocket jump v1

currently, the world is made of collidable CSGMeshes
staticbodies should do as well if required

when you look at this repo, you may notice some random areas scattered throughout the map. these are event areas, with their event dictated by their node group
1. Checkpoint areas set the player's checkpoint to their current position
2. Absorbant areas absorb rocket explosions
3. UnlockMap areas unlock new maps
4. Teleporter areas teleport the player to a specified destination

todo:
- the player center should be modified when crouching to make it closer to tf2 rocket jumping
- gravity/jump height is a bit off right now
- using a capsule hitbox does NOT work out if we're trying to replicate tf2 rj
