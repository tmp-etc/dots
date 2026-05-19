Fuzz for strange, inconsistent behaviour! 


When a request is sent, the bytes (typically) represent characters in a predefined encoding (such as UTF-8). However, you can also send Unicode escape sequences (Unicode code point values) to directly 'inject' characters that may be illegal or malformed in that encoding. Because applications often process Unicode at multiple layers (web servers, frameworks, databases), and each layer may handle Unicode differently, this technique can potentially bypass security filters that only check for normal character sequences in the expected encoding.

- Unicode control characters to make the filter stop input processing prematurely (because it found a control character) -> use your wordlist!
- Non-existant/malformed (multi-byte) characters like they use [[CVE-2024-12356 _ AttackerKB.pdf|here]]^[Basically, you can smuggle in any character you like, as long as you prefix it a byte that would fool the parse into thinking that the input is a multi-byte character in UTF-8. This 'multi-byte' character does not have to be valid in this case. The application takes the naive approach of assuming "hey, it's a multi-byte character, it can't be a quote! so it's fine to do a byte-by-byte copy without escaping anything!] and [[Attacking_APIs_using_JSON_Injection.pdf|here]]
- Unicode normalization or 'best fitting'^[see Orange Tsai's research] or something #todo make a wordlist?
- Emojis

```
\ud888'
\u00c0'
%C3%80'
\xC0'

In a situation where the application checks the input byte by byte, you might be able to smuggle in the single quote. This is because the C0 hex value represents 1100000, i.e. one of the bytes, which in UTF-8 represents a two-byte character.
```