fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_hello() {
        assert_eq!(2 + 2, 4);
    }
}
