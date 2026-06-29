https://portswigger.net/research/pre-auth-rce-in-forgerock-openam-cve-2021-35464 
> As my intention was to find truly impactful vulnerabilities rather than just "something", I decided to focus on the systems that are either open source or available to download and decompile.

https://j0vsec.com/post/cve-2021-43798/

https://pentesterlab.com/blog/how-to-start-reviewing-code

---

# INSECURE DESERIALIZATION

- You provide the serialized data/string, app deserializes it
- Your input end in some sort of custom serialization implementations where the serialized value is created through concatenation (see CVE-2025-49113)
    - could be named something like `objectmanager` (as in Magento)

If the app limits classes it is willing to deserialize or is deserializing an item it previously serialized itself...
- Check if the class (or any allowed classes) have known-exploitable magic methods, i.e a property (that you control) is used 'dangerously' inside the magic method, like `$this->$foo->something()` or `something_dangerous($this->$foo)` ... sounds stupid but hey


# ARBITRARY FILE WRITE / FILE UPLOAD

- The file gets turned into a file in underlying filesystem (I guess cloud storage like buckets handle this differently)
- You control the (part of the) filepath and the file content
- You are able to bypass sanitization of the filepath and content
- You find a path from which this file gets handled like an executable

This could range from classic webshells to messing with session data like CVE-2026-41940 where sessions are stored in plaintext file as key-value pairs and appending newline characters to a value enabled to insert new keys

# SSTI

***Look for***
- use of a <u>non</u> "logic-less" template engine, such as Mustache
- string interpolation / replacement used instead of the template engine? I.e the parameter gets replaced and then the template is passed to the template engine.
- user input ending up in an in-template func that's RCE-ish
- functionality to pass in arbitrary templates
	- as strings
	- from file upload


# RFI
Like `import`, `require` in PHP. Basically can you make the app take your code and include it in theirs.

# SUPPLY CHAIN / CICD ATTACKS

TBA!

# CALLING EXTERNAL CODE / BINARIES

You may only be able to manipulate the input <u>indirectly</u>! For instance, CVE-2025-60787.

The `motion` binary is called in `motioneye/motionctl.py` the following way:

```python
def start(deferred=False):
	# ...
    motion_cfg_path = os.path.join(settings.CONF_PATH, 'motion.conf')
    motion_log_path = os.path.join(settings.LOG_PATH, 'motion.log')
    motion_pid_path = os.path.join(settings.RUN_PATH, 'motion.pid')

    args = [binary, '-n', '-c', motion_cfg_path, '-d']
    # ...
    process = subprocess.Popen(
        args, 
        stdout=log_file, 
        stderr=log_file, 
        close_fds=True, 
        cwd=settings.CONF_PATH
    )
```

You cannot manipulate the values of `args`, but digging into the `motion` binary you eventually find that the program calls `execl()` with values defined in the `motion_cfg_path` config file (see [this](https://github.com/Motion-Project/motion/blob/master/src/picture.cpp#L73)).

So, <u>**DIG INTO THE BINARY CALLED AS WELL!**</u> and check for indirect input opportunities!

Yeah and also check if the input provided to the external executable can eval your code and interact with the OS

# AUTHN/Z BYPASSES

Especially when there are 'legit' functionalities that enable code execution, uploading webshells etc.


# ARBITRARY FILE READ

Check if the file is returned to you in some shape or form.

# SSRF

TBA, prolly only if you can hit some internal endpoint that enabled code exec etc...

