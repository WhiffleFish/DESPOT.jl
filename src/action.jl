function POMDPS.action_info(planner::DESPOTPlanner, b)
    empty!(planner.tree)
    ib = initial_belief(b, planner.sol.K)
    insert_belief(planner.tree, ib)

end

function initial_belief(b,K::Int)
    return [rand(b) for _ in 1:K]
end

function search!(planner::DESPOTPlanner, b_idx::Int, d::Int)
    if d ≤ 0
        return 0.0
    end
    b = planner.tree.b[b_idx]
    n_scenarios = length(b)

    v = estimate_value(b, planner.pomdp, d)
    # insert new actions into tree
    insert_actions!(planner, b_idx)

    cur_depth = planner.sol.D - d
    disc = discount(pomdp)^cur_depth

    # exhaustive search
    for (a,ba_idx) in tree.b_children[b_idx]
        # propagate particles to next beliefs
        R_ba = propagate!(planner, b_idx, a, ba_idx)
        ρ_ba = (1/planner.sol.K)*R_ba - planner.sol.λ
        for bp_idx in tree.ba_children[ba_idx]
            v_star′ = search!(planner, bp_idx, d-1)
        end
    end
end

function search!(planner::DESPOTPlanner, )
