package ru.spbu.detector.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import ru.spbu.detector.controller.filter.ApiKeyAuthFilter;

@Configuration
@EnableWebSecurity
@Order(1)
public class SecurityConfig {
    @Value("${detector.http.access-token-header-name}")
    private String principalRequestHeader;

    @Value("${detector.http.access-token}")
    private String principalRequestValue;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        var filter = new ApiKeyAuthFilter(principalRequestHeader);
        filter.setAuthenticationManager(authentication -> {
            var principal = (String) authentication.getPrincipal();
            if (principalRequestValue.equals(principal)) {
                throw new BadCredentialsException("");
            }
            authentication.setAuthenticated(true);
            return authentication;
        });

        http
            .securityMatcher("detection/**")
            .csrf().disable()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .addFilter(filter).authorizeHttpRequests().anyRequest().authenticated();
        return http.build();
    }
}
