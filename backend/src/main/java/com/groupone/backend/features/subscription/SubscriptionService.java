package com.groupone.backend.features.subscription;

import com.groupone.backend.features.icoin.ICoinService;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.subscription.dto.SubscriptionRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class SubscriptionService {
    private final ICoinService iCoinService;
    private final UserRepository userRepository;

    @Transactional
    public void purchasePro(User user, SubscriptionRequest request) {
        String description = "Pro Subscription - ";
        if (request.getMonths() >= 1200) {
            description += "Lifetime";
        } else {
            description += request.getMonths() + " months";
        }

        iCoinService.deductICoin(user, request.getPriceICoins(), description);

        user.setIsPro(true);

        LocalDateTime now = LocalDateTime.now();
        if (user.getProExpiryDate() != null && user.getProExpiryDate().isAfter(now)) {
            user.setProExpiryDate(user.getProExpiryDate().plusMonths(request.getMonths()));
        } else {
            user.setProExpiryDate(now.plusMonths(request.getMonths()));
        }

        userRepository.save(user);
    }
}
