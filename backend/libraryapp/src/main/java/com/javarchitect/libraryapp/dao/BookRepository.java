package com.javarchitect.libraryapp.dao;

import com.javarchitect.libraryapp.entity.Book;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookRepository extends JpaRepository<Book, Long> {
}
