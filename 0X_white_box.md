https://portswigger.net/research/pre-auth-rce-in-forgerock-openam-cve-2021-35464 
> As my intention was to find truly impactful vulnerabilities rather than just "something", I decided to focus on the systems that are either open source or available to download and decompile.

https://j0vsec.com/post/cve-2021-43798/

https://pentesterlab.com/blog/how-to-start-reviewing-code

---


# 🦊 GENERAL PROCESS FOR INJECTIONS

- Check out the README, think of the threat model or something
- Find starting points
	- Scan the source code with my custom semgrep rules, looking for sinks
	- Use Claude to find entrypoints
	- Browse the repo structure, search for keywords
- Prioritize
- Follow up on the sinks in an IDE, using the dataflow analysis, call hierarchy and other search functionalities to trace the sink to source (or at least to a point that renders exploitation unlikely)
- Check integrations
- Check out the dependencies
- Rinse and repeat the process for the dependencies/libraries
- Check out CI/CD and other development line vulns

---

# 🦊 INSECURE DESERIALIZATION

***Look for***
- deserialization of data (strings, 'binary' etc) you can provide
- custom serialization implementations where the serialized value is created through concatenation (see CVE-2025-49113); could be named something like `objectmanager` (as in Magento)

***Exploiting***

If the app limits classes it is willing to deserialize or is deserializing an item it previously serialized itself...
- Check if the class (or any allowed classes) have known-exploitable magic methods, i.e a property is used 'dangerously' inside the magic method, like `$this->$foo->something()` or `something_dangerous($this->$foo)`


# 🦊 ARBITRARY FILE WRITE

***Look for***
- File write operations where
	- the filename is <u>not</u> hardcoded or a constant
	- a hardcoded string is <u>not</u> appended to the user provided value
	- the filename is <u>not</u> sanitized with something like `basename`
	- the filename is <u>not</u> sanitized by removing some characters
	- the filename is <u>not</u> an app generate temporary file
    - the file data is <u>not</u> validate or specical characters stripped before writing to file (as was the case with CVE-2025-1302 where sessions are stored in plaintext file as key-value pairs; and appending newline characters to a value enabled to insert new keys)

***Exploiting***

> [!note] In Laravel
> Unprintable and invalid unicode characters will automatically be removed from file paths. Therefore, you may wish to sanitize your file paths before passing them to Laravel's file storage methods. File paths are normalized using the `League\Flysystem\WhitespacePathNormalizer::normalizePath` method.

> [!note] Uploading files?
> Like, does this differ from just file writes to local disk?



# 🦊 SSTI

***Look for***
- use of a <u>non</u> "logic-less" template engine, such as Mustache
- string interpolation / replacement used instead of the template engine? I.e the parameter gets replaced and then the template is passed to the template engine.
- user input ending up in an in-template func that's RCE-ish
- functionality to pass in arbitrary templates
	- as strings
	- from file upload


# 🦊 RFI
Like `import`, `require` in PHP. Basically can you make the app take your code and include it in theirs.

# 🦊 SUPPLY CHAIN / CICD ATTACKS

TBA!

# 🦊 CODE / COMMAND INJECTION

You may only be able to manipulate the input of the eval function <u>indirectly</u>! For instance, CVE-2025-60787.

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

# 🦊 CODE EVALUATION

TBA!

# 🦊 AUTHN/Z BYPASSES

Especially when there are 'legit' functionalities that enable code execution, uploading webshells etc.


# 🦊 ARBITRARY FILE READ

Check if the file is returned to you in some shape or form.

# 🦊 SSRF

TBA, prolly only if you can hit some internal endpoint that enabled code exec etc...

