package com.groupone.backend.features.icoin;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ICoinService {
    private final UserRepository userRepository;
    private final ICoinTransactionRepository transactionRepository;

    @Transactional
    public void deductICoin(User user, int amount, String featureName) {
        if (user.getICoinBalance() < amount) {
            throw new InsufficientICoinException("Insufficient iCoin balance for " + featureName);
        }
        user.setICoinBalance(user.getICoinBalance() - amount);
        userRepository.save(user);

        ICoinTransaction transaction = ICoinTransaction.builder()
                .user(user)
                .amount(amount)
                .transactionType(TransactionType.DEDUCT)
                .description("Payment for: " + featureName)
                .balanceAfter(user.getICoinBalance())
                .build();
        transactionRepository.save(transaction);
    }

    @Transactional
    public void addICoin(User user, int amount, String description) {
        user.setICoinBalance(user.getICoinBalance() + amount);
        userRepository.save(user);

        ICoinTransaction transaction = ICoinTransaction.builder()
                .user(user)
                .amount(amount)
                .transactionType(TransactionType.ADD)
                .description(description)
                .balanceAfter(user.getICoinBalance())
                .build();
        transactionRepository.save(transaction);
    }

    @Transactional
    public void setICoinBalance(User user, int amount, String description) {
        user.setICoinBalance(amount);
        userRepository.save(user);

        ICoinTransaction transaction = ICoinTransaction.builder()
                .user(user)
                .amount(amount)
                .transactionType(TransactionType.SET)
                .description(description)
                .balanceAfter(user.getICoinBalance())
                .build();
        transactionRepository.save(transaction);
    }

    public List<ICoinTransaction> getAllTransactions() {
        return transactionRepository.findAllByOrderByCreatedAtDesc();
    }
}
