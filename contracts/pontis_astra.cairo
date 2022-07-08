# Declare this file as a StarkNet contract.
%lang starknet

########################
  # L2 BRIDGE CONTRACT#
########################

# - Stake Anima at coord is called on L1 bridge and L2 recieves message with anima_id, starknet_account of owner, coordinates
# - L2 bridge calls codex loci's stake and codex materia's staked and unstaked