---
name: java-build-resolver
description: Diagnose and resolve scoped Java build, compile, test, packaging, dependency, Maven, Gradle, Surefire, WAR, resource-filtering, profile, plugin, and classpath failures. Use for prompts such as "java-build-resolver", "/java-build-resolver", "fix Maven build", "mvn test failed", "mvn package failed", "Gradle Java failure", "Java compile error", "Surefire skipped tests", "WAR packaging failed", "dependency resolution failed", "wrong Java version", or when Java validation blocks implementation and Codex should apply the smallest correct fix.
---

# Java Build Resolver

## Principle

Fix the root cause with the smallest change compatible with the repository's Java version, framework, build profiles, and packaging model. Do not turn build resolution into dependency modernization.

Use `java-patterns` for code design decisions. Use `java-legacy-discovery` when a proposed fix may change legacy behavior.

## Safety Rules

- Inspect the wrapper, `pom.xml`, parent POM, Gradle files, toolchains, profiles, settings references, and CI commands before running validation.
- Prefer `./mvnw` or `./gradlew` when present; otherwise use the installed tool only after checking its version.
- Start with a focused module, test, or lifecycle phase.
- Do not run broad dependency upgrades, Maven version updates, Gradle refreshes, cache deletion, repository mirror changes, or plugin upgrades without explicit need and approval.
- Do not expose credentials from `settings.xml`, environment variables, filtered resources, or repository URLs.
- Do not add `skipTests`, disable lint/check plugins, suppress compiler errors, or remove failing tests to make the build green.
- Do not assume `BUILD SUCCESS` means tests ran; inspect Surefire/Failsafe and profile output.

## Workflow

1. Capture the exact failing command, working directory, active profile, Java version, and first root-cause error.
2. Inspect build topology:
   - wrapper and build tool version
   - modules and parent inheritance
   - compiler source/target/release
   - packaging and container assumptions
   - resource filtering and active profiles
   - Surefire/Failsafe test selection and skip flags
   - local/system-scope JARs, `extdirs`, annotation processors, and generated sources
3. Reproduce narrowly with existing repository commands.
4. Trace the failure to source, configuration, classpath, profile, or environment.
5. Apply one scoped fix.
6. Rerun the same command, then the next relevant focused validation.
7. Report commands, active profiles, whether tests actually ran, and remaining failures.

## Command Selection

Prefer repository wrappers:

```bash
./mvnw -pl <module> -am test
./mvnw -pl <module> -Dtest=<TestName> test
./mvnw -pl <module> -am package
./gradlew :<module>:test --tests '<TestClass>'
./gradlew :<module>:compileJava
```

When no wrapper exists and the repository uses Maven or Gradle:

```bash
mvn -pl <module> -am test
mvn -pl <module> -Dtest=<TestName> test
gradle :<module>:test
```

Use `mvn help:active-profiles`, `mvn help:effective-pom`, or Gradle dependency/task reports only when profile inheritance or configuration is part of the failure. These commands may reveal environment details; summarize safely.

## Failure Guide

| Symptom | Inspect First | Preferred Direction |
| --- | --- | --- |
| unsupported source/release | runtime JDK, compiler plugin, toolchain | use the repository-supported JDK or correct scoped compiler config |
| cannot find symbol/package | first compile error, imports, module dependency, generated source | fix local code or declared module edge before changing versions |
| dependency not found | coordinates, repositories, profile, local/system JAR | verify intended source; avoid broad upgrades |
| tests silently absent | Surefire/Failsafe config, naming, profile, `skipTests` | run the intended phase and prove test count |
| test runtime class missing | test scope, plugin provider, classpath conflict | correct narrow dependency scope or plugin config |
| resource placeholder unresolved | active profile, filtering directories, property names | activate/correct the intended non-secret profile |
| WAR packaging failure | webapp path, web.xml mode, plugin version, generated resources | preserve container and servlet-generation assumptions |
| duplicate classes/resources | dependency tree, local JARs, shaded content | remove only the unintended duplicate source |
| linkage error | compiled/runtime version mismatch | align the specific dependency edge without sweeping upgrades |
| encoding failure | project/source/resource encoding | declare or use repository-intended encoding consistently |

## Legacy Build Checks

For Java 8-era Maven WAR projects, explicitly inspect:

- plugin versions that may require an older JDK runtime
- `source`/`target` versus the JDK actually running Maven
- `maven.compiler.extdirs`, `systemPath`, and JARs under `WEB-INF/lib`
- resource directories selected by Maven profiles
- Tomcat/Jetty plugin configuration versus packaging-only validation
- Spring XML and servlet resources excluded or filtered by profile
- Surefire settings that skip all tests by default

Treat missing proprietary JARs or environment-only artifacts as blockers to document, not invitations to download unverified binaries.

## Dependency Rules

- Read `dependencyManagement` and parent POMs before adding or overriding a version.
- Use dependency-tree output to identify the exact conflict.
- Avoid major upgrades and Java/framework migrations during build repair.
- Preserve exclusions and repository mirrors unless evidence shows they are wrong.
- Request approval before commands that require network access or materially rewrite lockfiles/build metadata.

## Stop Conditions

Stop and report when:

- the required JDK, proprietary JAR, parent POM, private repository, or credentials are unavailable
- the same root error remains after three focused attempts
- the next fix requires framework, Java, servlet namespace, or build-system migration
- a production-only profile or service would be needed to validate
- overlapping user changes make a safe scoped edit impossible

## Output Expectations

```text
Build status: SUCCESS/FAILED
Root cause: <specific cause>
Environment: <Java/build tool/module/profile>
Fixes:
- <file:line and concise change>
Validation:
- <command>: <result, including test count or skipped state>
Remaining:
- <blocker or None>
```

