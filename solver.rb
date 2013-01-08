class Solver
  def start_problem(pos)
    Position.initialize_zobrist_hash_seeds
    pos.generata_hash
  end
end
