while true do
    task.wait(1)
    game:GetService("DataStoreService"):GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
    game:GetService("DataStoreService"):GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)
end
