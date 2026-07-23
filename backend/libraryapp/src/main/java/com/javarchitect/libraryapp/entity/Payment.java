package com.javarchitect.libraryapp.entity;

import jakarta.persistence.*;
import lombok.Data;

@Table(name = "payment")
@Data
@Entity
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private String id;

    @Column(name = "amount")
    private double amount;

    @Column(name = "user_email")
    private String userEmail;
}
