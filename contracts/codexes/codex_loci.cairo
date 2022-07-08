# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.alloc import alloc

from starkware.cairo.common.serialize import serialize_word

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.signature import verify_ecdsa_signature  # ?
from starkware.starknet.common.syscalls import get_tx_signature  # ?
from starkware.starknet.common.syscalls import get_caller_address  # ?

from starkware.cairo.common.math import assert_nn

from starkware.cairo.common.math_cmp import is_le_felt

from starkware.cairo.common.uint256 import Uint256

#############################
# ANIMA MAP CONTRACT #
#############################
# - settle at point
# - viewing anima at point
# - viewing point of anima

# #### CONTRACT FUNCTIONS WILL BE CALLED BY PONTIS_ASTRA FOR STAKING/UNSTAKING #####
# #### CONTRACT FUNCTIONS WILL BE CALLED BY CODEX_MATERIA AND CODEX_BELLICUM FOR COORDINATE VIEW #####

# #### CHECKS ARE STILL NEEDED! #####
# - You can't spawn galaxies where one is already positioned
# #### MIGHT CONSIDER DISTANCE CALCULATIONS #####

########################
#   STRUCTURES
########################

struct Vec2D:
    member x : Uint256
    member y : Uint256
end

########################
#   EVENTS
########################
@event
func anima_staked(anima_id : Uint256, coord : Vec2D):
end

@event
func anima_unstaked(anima_id : Uint256):
end
########################
#   STORAGE
########################

@storage_var
func anima_coords(anima_id : Uint256) -> (coord : Vec2D):
end

@storage_var
func coords_to_anima(coord : Vec2D) -> (anima_id : Uint256):
end

########################
#   VIEWS
########################
@view
func get_anima_coord{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    anima_id : Uint256
) -> (coord : Vec2D):
    let (coord) = anima_coords.read(anima_id)

    return (coord)
end

########################
#   EXTERNALS
########################

@external
func stake{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    anima_id : Uint256, coord : Vec2D
):
    anima_coords.write(anima_id, coord)
    coords_to_anima.write(coord, anima_id)
    anima_staked.emit(anima_id, coord)

    return ()
end

# ## Null the coords and id ###
@external
func unstake{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(anima_id : Uint256):
    let (coord) = anima_coords.read(anima_id)
    anima_coords.write(anima_id, Vec2D(Uint256(0, 0), Uint256(0, 0)))

    coords_to_anima.write(coord, Uint256(0, 0))
    anima_unstaked.emit(anima_id)

    return ()
end
