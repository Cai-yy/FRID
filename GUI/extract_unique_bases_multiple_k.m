function [Unique_basis_cell] = extract_unique_bases_multiple_k(X, cluster_num_list, labels_cell, rank)
    Unique_basis_cell = {length(cluster_num_list)};

    for idx = 1: length(cluster_num_list)
        labels = labels_cell{idx};
        [uniqueBases, sharedBasis,clusterBases,ev_cumsum] = extractUniqueBases(X, labels, 'rank', rank);
        Unique_basis_cell{idx} = uniqueBases;
    end
end