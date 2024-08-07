
"""
Take in a number (number of data points) and return a tuple of three vectors
    1st vector: training indices
    2nd vector: validation indices
    3rd vector: test indices
"""
function make_train_test_splits(num_reads; train_valid_test_ratio=[0.8,0.1,0.1])
    random_permuted_indices = shuffle(1:num_reads)
    train_end = floor(Int, num_reads*train_valid_test_ratio[1])
    valid_end = train_end + floor(Int, num_reads*train_valid_test_ratio[2])
    train_indices = random_permuted_indices[1:train_end]
    valid_indices = random_permuted_indices[train_end+1:valid_end]
    test_indices = random_permuted_indices[valid_end+1:end]
    return train_indices, valid_indices, test_indices
end


