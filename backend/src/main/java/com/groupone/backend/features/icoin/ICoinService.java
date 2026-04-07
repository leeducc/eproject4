package com.groupone.backend.features.icoin;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ICoinService {
    private final UserRepository userRepository;
    private final ICoinTransactionRepository transactionRepository;

    @Transactional
    public void deductICoin(User user, int amount, String featureName) {
        log.info("Deducting {} iCoins from user {} for {}", amount, user.getId(), featureName);
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
        log.info("Adding {} iCoins to user {}: {}", amount, user.getId(), description);
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
    public void commitHeldCoins(User user, int amount, String description) {
        log.info("Committing {} held iCoins for user {}: {}", amount, user.getId(), description);
        if (user.getHeldICoinBalance() < amount) {
            throw new InsufficientICoinException("Insufficient held iCoin balance: " + amount);
        }
        user.setHeldICoinBalance(user.getHeldICoinBalance() - amount);
        userRepository.save(user);

        ICoinTransaction transaction = ICoinTransaction.builder()
                .user(user)
                .amount(amount)
                .transactionType(TransactionType.COMMIT)
                .description(description)
                .balanceAfter(user.getICoinBalance())
                .build();
        transactionRepository.save(transaction);
    }

    @Transactional
    public void refundHeldCoins(User user, int amount, String description) {
        log.info("Refunding {} held iCoins for user {}: {}", amount, user.getId(), description);
        if (user.getHeldICoinBalance() < amount) {
            throw new InsufficientICoinException("Insufficient held iCoin balance to refund: " + amount);
        }
        user.setHeldICoinBalance(user.getHeldICoinBalance() - amount);
        user.setICoinBalance(user.getICoinBalance() + amount);
        userRepository.save(user);

        ICoinTransaction transaction = ICoinTransaction.builder()
                .user(user)
                .amount(amount)
                .transactionType(TransactionType.REFUND)
                .description(description)
                .balanceAfter(user.getICoinBalance())
                .build();
        transactionRepository.save(transaction);
    }

    @Transactional
    public void holdCoins(User user, int amount, String description) {
        log.info("Holding {} iCoins for user {}: {}", amount, user.getId(), description);
        if (user.getICoinBalance() < amount) {
            throw new InsufficientICoinException("Insufficient iCoin balance to hold: " + amount);
        }
        user.setICoinBalance(user.getICoinBalance() - amount);
        user.setHeldICoinBalance(user.getHeldICoinBalance() + amount);
        userRepository.save(user);

        ICoinTransaction transaction = ICoinTransaction.builder()
                .user(user)
                .amount(amount)
                .transactionType(TransactionType.HOLD)
                .description(description)
                .balanceAfter(user.getICoinBalance())
                .build();
        transactionRepository.save(transaction);
    }

    @Transactional
    public void setICoinBalance(User user, int amount, String description) {
        log.info("Setting iCoin balance for user {} to {}: {}", user.getId(), amount, description);
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

    public List<ICoinTransaction> getTransactionsByUser(Long userId) {
        return transactionRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<ICoinTransaction> getAllTransactions() {
        return transactionRepository.findAllByOrderByCreatedAtDesc();
    }
}
