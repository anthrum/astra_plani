# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.signature import verify_ecdsa_signature    # ?
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_mul,
)
from starkware.starknet.common.syscalls import (
    get_tx_signature,
    get_caller_address,
    get_block_number,
    get_block_timestamp,
)
########################
# REQS
# - define balances for coordinates
# - timestamp/epoch                     
# - update balance                      
# - view balance
# - retrieve atomus (Mint ERC-20 ATOMUS)
# - Check for max supply or take traditional route of max supply on ERC-20 contract?



                                    ##### CONTRACT WILL CALL CODEX_LOCI TO RETRIEVE COORDINATE DATA #####
                            ##### CONTRACT FUNCTIONS WILL BE CALLED BY ------ FOR STAKING/UNSTAKING #####
                   ##### CONTRACT FUNCTIONS WILL BE CALLED BY CODEX_BELLICUM FOR ATOMUS_DENSITY MANIPULATION #####
 ##### CONTRACT WILL EITHER OWN ATOMUS ERC-20 MINTABLE CONTRACT, OR CALL FUNCTION OF CONTRACT ------ THAT OWNS ATOMUS ERC-20 #####



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
func atomus_materialized_event(coord : Vec2D, atomus_yielded : Uint256, tn: Uint256):
end

@event
func atomus_subtracted(coord : Vec2D, atomus_subtracted : Uint256, tn: Uint256):
end

########################
#   STORAGE
########################

# amount of atomus at coordinate  (we're choosing to have atomus stored at coordinates for artistic/lore/gaming purposes)
@storage_var
func atomus_density(coord: Vec2D) -> (density: Uint256):
end

@storage_var
func last_materialization(coord: Vec2D) -> (t0_materialized: Uint256):
end


########################
#   VIEWS
########################
@view
func get_atomus_density{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D) -> (density: Uint256):

    let (density) = atomus_density.read(coord)

    return (density)
end

@view
func get_last_materialization{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D) -> (t0_materialized: Uint256):
    let (t0_materialized) = last_materialization.read(coord)

    return(t0_materialized)
end

########################
#   INTERNALS
########################

# Updates timestamp for future yield reward calculation
func update_materialization_timestamp{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D) -> (updated_timestamp: Uint256): 
    let (ft) = get_block_timestamp()
    let t = Uint256(ft,0)
    last_materialization.write(coord, t )     
    return (t)
end

                                            ##### UPDATE "BALANCE" #####
# The following functions is called either by materialization (increase is called by materialize_atomus) or by bellicum contract
func increase_atomus_density{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D, amount_added: Uint256):
    let (last_atomus_density) = get_atomus_density(coord)
    let (new_atomus_density, _) = uint256_add(last_atomus_density, amount_added)
    atomus_density.write(coord, new_atomus_density)
    return ()
end

# The following function is called by codex bellicum
func decrease_atomus_density{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D, amount_subtracted: Uint256):
    let (last_atomus_density) = get_atomus_density(coord)
    # A minimum barrier check will have to established for new_atomus_density. Part of the coordinate balance will be "safe" from astral warfare.
    let (new_atomus_density) = uint256_sub(last_atomus_density, amount_subtracted)
    atomus_density.write(coord, new_atomus_density)
    return ()
end

                                        ##### Calculate amount_materialized #####
func calculate_amount_materialized{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D, dt: Uint256) -> (amount_materialized: Uint256):
# amount_materialized will be an exponential or power function of dt for compunding effect, not linear as is now. Incentivizes keeping atomus on coordinate
# assert carry over 0   --- TO DO
    let (amount_materialized,_) = uint256_mul(dt, Uint256(1000000000000000000,0))   
    return (amount_materialized)
end



    
########################
#   EXTERNALS
########################

@external 
func materialize_atomus{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D):
    # put requiremens/ calculations
    let (t0) = get_last_materialization(coord)
    let (tn) = update_materialization_timestamp(coord)
    let (dt) = uint256_sub(tn, t0)
    # calculate
    let (amount_materialized) = calculate_amount_materialized(coord, dt)
    # update balance
    increase_atomus_density(coord, amount_materialized)
    # emit materialization event
    atomus_materialized_event.emit(coord, amount_materialized, tn)
    return ()
end


                            #################################################################
                                ### FOLLOWING FUNCTIONS WILL BE CALLED BY ---- ###
                            #################################################################

# The following function is to simulate the initial timestamp. This will be called by an authorized third contract --- ADD CHECK
@external
func staked{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D):
    update_materialization_timestamp(coord)
    return()
end

@external
func unstaked{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(coord : Vec2D):
    update_materialization_timestamp(coord)
    # Transfer portion of coordinate balance (atomus_density) to account of Anima owner by calling ERC-20 ATOMUS contract mint to
    return()
end


