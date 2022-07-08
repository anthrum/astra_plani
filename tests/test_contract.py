

"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CODEX_LOCI = os.path.join("contracts", "codex_loci.cairo")
CODEX_MATERIA = os.path.join("contracts", "codex_materia.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_staking():
    """Tests if staking an anima ID at coordinate is later retrievable"""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the CODEX_LOCI.
    codex_loci_contract = await starknet.deploy(
        source=CODEX_LOCI,
    )

    # Deploy the CODEX_MATERIA.
    codex_materia_contract = await starknet.deploy(
        source=CODEX_MATERIA,
    )

    # stake id 1 at coord (5, 6)
    await codex_loci_contract.stake(
        anima_id=(1,0),
        coord=((5,0), (6,0)) 
    ).invoke()

    # Check the result of coordinates().
    execution_info = await codex_loci_contract.get_anima_coord((1,0)).call()

    assert execution_info.result.coord.x.low == 5
    assert execution_info.result.coord.y.low == 6

