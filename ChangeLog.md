
#### [Current]
 * [bb87455](../../commit/bb87455) - __(Alex Lynch)__ Cleanup and bug fixes.
 * [c64ad19](../../commit/c64ad19) - __(Alex Lynch)__ Mark as v3.0.0.a.4
 * [68d653c](../../commit/68d653c) - __(Alex Lynch)__ Update version release script.
 * [e600106](../../commit/e600106) - __(Alex Lynch)__ Mark as v3.0.0.a.3
 * [7c660d0](../../commit/7c660d0) - __(Alex Lynch)__ Mark as v3.0.0.a.2

#### v3.0.0-a.1
 * [38ba4a3](../../commit/38ba4a3) - __(Alex Lynch)__ Correct SemVer syntax.
 * [cf55b51](../../commit/cf55b51) - __(Alex Lynch)__ Update podspec with v3.0.0.a1
 * [1657bd8](../../commit/1657bd8) - __(Alex Lynch)__ Marking v3.0.0.a1
 * [7e6968b](../../commit/7e6968b) - __(Alex Lynch)__ All test files are compiling. 2 tests disabled. Entering alpha state.
 * [0441a74](../../commit/0441a74) - __(Alex Lynch)__ Reenabled FinallyTests. Code cleanup.
 * [6c65cdf](../../commit/6c65cdf) - __(Alex Lynch)__ Restored UploadPipeline test.
 * [62dd32a](../../commit/62dd32a) - __(Alex Lynch)__ Cleanup and syntax stabilization. Half of the tests are reenabled.
 * [d431595](../../commit/d431595) - __(Alex Lynch)__ Reenable MergeSortTest.
 * [d66d13f](../../commit/d66d13f) - __(Alex Lynch)__ Reenable AsyncFlowControlTests.
 * [7ffe0cb](../../commit/7ffe0cb) - __(Alex Lynch)__ Beta implementation of Error parameterized links.
 * [0addf8a](../../commit/0addf8a) - __(Alex Lynch)__ Replace @dynamicCallable with Swift 5.2 callAsFunction feature.
 * [909d311](../../commit/909d311) - __(Alex Lynch)__ Rename AsyncBlockPerformer generic argument to P in preparation for more generic constraints.
 * [7cd9756](../../commit/7cd9756) - __(Alex Lynch)__ Rename "completion" methods in Link with a reactive-programming convention.
 * [e3bb2b6](../../commit/e3bb2b6) - __(Alex Lynch)__ Refine downstream `response` and `error` handlers; remove upstream error handlers. Errors no longer flow up HoneyBee chains.
 * [6eab4f1](../../commit/6eab4f1) - __(Alex Lynch)__ Implement and test `result` async accessor. For the first time in honeybee, errors flow down stream.
 * [846b7aa](../../commit/846b7aa) - __(Alex Lynch)__ Avoid crashing where possible in response to internal errors.
 * [6a5aadb](../../commit/6a5aadb) - __(Alex Lynch)__ Abstract ConcurrentBox from JoinPoint.
 * [1f02e69](../../commit/1f02e69) - __(Alex Lynch)__ Propagate ErrorContext to dependents.
 * [36da234](../../commit/36da234) - __(Alex Lynch)__ Excise FailableResult and friends.
 * [1c3a256](../../commit/1c3a256) - __(Alex Lynch)__ Repair the broken and deprecated `each` function.
 * [f12d318](../../commit/f12d318) - __(Alex Lynch)__ Improve comment coverage.
 * [b7cd2a2](../../commit/b7cd2a2) - __(Alex Lynch)__ Use more diverse async block performers for code coverage.
 * [c4acb10](../../commit/c4acb10) - __(Alex Lynch)__ Rename async function wrapper types for consistency.
 * [75a983a](../../commit/75a983a) - __(Alex Lynch)__ "Move to" operator (>>) evaluates lvals on the rval link's performer.
 * [6953782](../../commit/6953782) - __(Alex Lynch)__ Improve code coverage.
 * [49588ba](../../commit/49588ba) - __(Alex Lynch)__ Simplify the AsyncFlowControl code and improve the test.
 * [6a49d29](../../commit/6a49d29) - __(Alex Lynch)__ Move async family's function argument to the final position to permit trailing closures.
 * [2d0c73c](../../commit/2d0c73c) - __(Alex Lynch)__ Conditionally import CoreData.
 * [1409903](../../commit/1409903) - __(Alex Lynch)__ Basic if/else_if/else flow control.
 * [7c0af84](../../commit/7c0af84) - __(Alex Lynch)__ Implement merge sort test. Mark finally as @discardableResult
 * [0e466fa](../../commit/0e466fa) - __(Alex Lynch)__ Implement a non-HoneyBee solution to UploadPipleline test.
 * [fcecf85](../../commit/fcecf85) - __(Alex Lynch)__ Implement AsyncPerformer-bound function wrappers and implement UploadPipeline tests.
 * [933b98f](../../commit/933b98f) - __(Alex Lynch)__ Introduce some non-topical tests for coverage.
 * [0273d04](../../commit/0273d04) - __(Alex Lynch)__ Redefine async function family to return a function wrapper that is not defined in terms of Link.
 * [b281211](../../commit/b281211) - __(Alex Lynch)__ Remove instance-curry forms from async function family.
 * [2fda2e4](../../commit/2fda2e4) - __(Alex Lynch)__ Rename function wrappers for greater clarity.
 * [3463652](../../commit/3463652) - __(Alex Lynch)__ Convert some multi-path tests to async curry syntax.
 * [a82d67b](../../commit/a82d67b) - __(Alex Lynch)__ Beta async curry syntax. Introduce AsyncTrace. Cleanup weaknesses in .reduce and .each identified by new Test Plan.
 * [dad5f6e](../../commit/dad5f6e) - __(Alex Lynch)__ Mark as v2.8.2
 * [4f24cee](../../commit/4f24cee) - __(Alex Lynch)__ Mark as v2.8.2
 * [580413a](../../commit/580413a) - __(Alex Lynch)__ Compatibility with Swift 5.1
 * [5ea36ba](../../commit/5ea36ba) - __(Alex Lynch)__ Update generator to handle same-type unfulfilled parameters in bind family.
 * [22e2b83](../../commit/22e2b83) - __(Alex Lynch)__ Update Generate.rb to generate AAC-form binds and Links with async performer generic params.
 * [cb85cea](../../commit/cb85cea) - __(Alex Lynch)__ Construct UnitTests for swift team to review compiler segfault.
 * [1a34d98](../../commit/1a34d98) - __(Alex Lynch)__ Define HoneyBee.async family of start behaviors. Implement Chris Lattner's coroutine example as a unit test.
 * [aafd767](../../commit/aafd767) - __(Alex Lynch)__ Conform ErrorContext to Error. (!!)
 * [a733d19](../../commit/a733d19) - __(Alex Lynch)__ Convert drop() to a var and restyle tests.
 * [0aa7923](../../commit/0aa7923) - __(Alex Lynch)__ Beta all new error tracing behavior.
 * [417524e](../../commit/417524e) - __(Alex Lynch)__ Rename magic aysnc keyword `await` after common style.
 * [86cf816](../../commit/86cf816) - __(Alex Lynch)__ Move await behaviors into Link and implement tail closure.
 * [7acee1f](../../commit/7acee1f) - __(Alex Lynch)__ Rename setBlockPerformer(_:) to move(to:).
 * [d48c913](../../commit/d48c913) - __(Alex Lynch)__ Implement type-checked AsyncBlockPerformer matching in Link, SafeLink, and JoinPoint. Make Link's public interface immutable and redefine AsyncBlockPerformer changing semantics.
 * [dc8eaf6](../../commit/dc8eaf6) - __(Alex Lynch)__ R publicize FailableResult as a typealias on Result<T, Error>
 * [386d9c0](../../commit/386d9c0) - __(Alex Lynch)__ Define types for common GCD dispatch queues as AsyncBlockPerformers.
 * [6f89ac5](../../commit/6f89ac5) - __(Alex Lynch)__ Xcode-suggested project reorganization.
 * [72a6a26](../../commit/72a6a26) - __(Alex Lynch)__ Mark as v2.8.1
 * [142da4e](../../commit/142da4e) - __(Alex Lynch)__ Change project hosting to github.
 * [5cf332d](../../commit/5cf332d) - __(Alex Lynch)__ Mark as v2.8
 * [46b05c5](../../commit/46b05c5) - __(Alex Lynch)__ Implement swift 5.0 support.
 * [c94b9ef](../../commit/c94b9ef) - __(Alex Lynch)__ Mark as v2.7.1
 * [430f228](../../commit/430f228) - __(Alex Lynch)__ Mark as v2.7.1
 * [ad8c7af](../../commit/ad8c7af) - __(Alex Lynch)__ Mark as v2.7.1
 * [62f638b](../../commit/62f638b) - __(Alex Lynch)__ Add missing documentation for SafeLink.
 * [e0f5a6d](../../commit/e0f5a6d) - __(Alex Lynch)__ Fix mistake in bind documentation.
 * [06e3796](../../commit/06e3796) - __(Alex Lynch)__ Mark as v2.7.0
 * [62bb74a](../../commit/62bb74a) - __(Alex Lynch)__ Update to swift 4.2.
 * [31c5942](../../commit/31c5942) - __(Alex Lynch)__ Add map to FailableResult monad.
 * [d88c5f6](../../commit/d88c5f6) - __(Alex Lynch)__ Mark as v2.6.2
 * [ac90178](../../commit/ac90178) - __(Alex Lynch)__ Mark as v2.6.2
 * [71fd985](../../commit/71fd985) - __(Alex Lynch)__ Implement new bind flavors.
 * [653bcdf](../../commit/653bcdf) - __(Alex Lynch)__ Improved error logging for AtomicValue.
 * [a6ab1b4](../../commit/a6ab1b4) - __(Alex Lynch)__ Initial implementation of SafeLink strategy.
 * [52090f7](../../commit/52090f7) - __(Alex Lynch)__ Mark as v2.6.1
 * [25872b4](../../commit/25872b4) - __(Alex Lynch)__ Mark as v2.6.1
 * [c854469](../../commit/c854469) - __(Alex Lynch)__ Widen the context switching overhead margin for some multi-path tests.
 * [c118436](../../commit/c118436) - __(Alex Lynch)__ Signal all internal errors through the internalFailureResponse handler.
 * [9e71e0d](../../commit/9e71e0d) - __(Alex Lynch)__ Publicize FaultResponse.evaluate and improve debugger interaction.
 * [f5fadef](../../commit/f5fadef) - __(Alex Lynch)__ Standardize release file.
 * [8accc7b](../../commit/8accc7b) - __(Alex Lynch)__ Mark as v2.6.0
 * [20e7794](../../commit/20e7794) - __(Alex Lynch)__ Alter behavior of `setCompletionHandler` to permit only one error.
 * [842aede](../../commit/842aede) - __(Alex Lynch)__ Mark as v2.5.2
 * [a583c7e](../../commit/a583c7e) - __(Alex Lynch)__ Synchronize access to Honey.*response FaultResponses.
 * [3beab26](../../commit/3beab26) - __(Alex Lynch)__ Implement get getBlockPerformer utility method and tests.
 * [e5b3011](../../commit/e5b3011) - __(Alex Lynch)__ Mark as v2.5.1
 * [f2021d1](../../commit/f2021d1) - __(Alex Lynch)__ Mark as v2.5.1
 * [20f1209](../../commit/20f1209) - __(Alex Lynch)__ Inform cocoapods of swift 4.1 support.
 * [c7b3ee4](../../commit/c7b3ee4) - __(Alex Lynch)__ Mark as v2.5
 * [1e88930](../../commit/1e88930) - __(Alex Lynch)__ Mark as v2.5
 * [a40fafa](../../commit/a40fafa) - __(Alex Lynch)__ Mark as v2.5
 * [23363e8](../../commit/23363e8) - __(Alex Lynch)__ Updates for Swift 4.1
 * [4c4cb63](../../commit/4c4cb63) - __(Alex Lynch)__ Implement sanity check that conjoined link's block performers are equal.
 * [a173424](../../commit/a173424) - __(Alex Lynch)__ Mark as v2.4.2
 * [ce2e023](../../commit/ce2e023) - __(Alex Lynch)__ Re-write optionally to be contract correct in the face of errors.
 * [82a9818](../../commit/82a9818) - __(Alex Lynch)__ Mark as v2.4.1
 * [260a590](../../commit/260a590) - __(Alex Lynch)__ Publicize new compound conjoin feature.
 * [7b89845](../../commit/7b89845) - __(Alex Lynch)__ Mark as v2.4
 * [ccfdd0b](../../commit/ccfdd0b) - __(Alex Lynch)__ Mark as v2.4
 * [ab44a49](../../commit/ab44a49) - __(Alex Lynch)__ Add compound conjoin behavior.
 * [d88b61f](../../commit/d88b61f) - __(Alex Lynch)__ Mark as v2.3.1
 * [82cd5d9](../../commit/82cd5d9) - __(Alex Lynch)__ Publicize the internal failure response.
 * [4e84c8e](../../commit/4e84c8e) - __(Alex Lynch)__ Mark as v2.3
 * [57778fe](../../commit/57778fe) - __(Alex Lynch)__ Implement "blockless" HoneyBee.start()
 * [73eeb41](../../commit/73eeb41) - __(Alex Lynch)__ Mark as v2.2.6
 * [0be72dd](../../commit/0be72dd) - __(Alex Lynch)__ Proper SPM support.
 * [8d0d8be](../../commit/8d0d8be) - __(Alex Lynch)__ Mark as v2.2.5
 * [6d04799](../../commit/6d04799) - __(Alex Lynch)__ Beta support for SPM.
 * [ebd28b6](../../commit/ebd28b6) - __(Alex Lynch)__ Improve release automation.
 * [5d96199](../../commit/5d96199) - __(Alex Lynch)__ Mark as v2.2.4

#### v2.2.3
 * [84a7649](../../commit/84a7649) - __(Alex Lynch)__ Mark as v2.2.3 Improve release automation.

#### v2.2.2
 * [023e11d](../../commit/023e11d) - __(Alex Lynch)__ Mark as v2.2.2

#### v2.2.1
 * [5a255cc](../../commit/5a255cc) - __(Alex Lynch)__ Mark as v2.2.1
 * [3f43e2c](../../commit/3f43e2c) - __(Alex Lynch)__ Improve Readme.
 * [6e2774b](../../commit/6e2774b) - __(Alex Lynch)__ Correct author's email address.

#### v2.2
 * [11f9172](../../commit/11f9172) - __(Alex Lynch)__ Mark as v2.2
 * [5277323](../../commit/5277323) - __(Alex Lynch)__ Implement non-returning limit.

#### v2.1.2
 * [1b99b07](../../commit/1b99b07) - __(Alex Lynch)__ Mark as v2.1.2
 * [1cc73d5](../../commit/1cc73d5) - __(Alex Lynch)__ Introduce instance curry forms of bind()

#### v2.1.1
 * [1b3cc70](../../commit/1b3cc70) - __(Alex Lynch)__ Mark as v2.1.1

#### v2.1
 * [88c6eef](../../commit/88c6eef) - __(Alex Lynch)__ Mark as v2.1.
 * [2559ef9](../../commit/2559ef9) - __(Alex Lynch)__ Implement setCompletionHandler(:)
 * [9c426b4](../../commit/9c426b4) - __(Alex Lynch)__ Implement setCompletionHandler(:).
 * [1dc3f20](../../commit/1dc3f20) - __(Alex Lynch)__ Remove @discardableResult from chain with KeyPath.
 * [7f272c6](../../commit/7f272c6) - __(Alex Lynch)__ Add Error property to ErrorContext and collapse the two-arg forms of error handler

#### v2.0.5
 * [e02f3c5](../../commit/e02f3c5) - __(Alex Lynch)__ Mark as v2.0.5 (Podspec fix).

#### v2.0.4
 * [a2b6a0d](../../commit/a2b6a0d) - __(Alex Lynch)__ Mark as v2.0.4
 * [de7647a](../../commit/de7647a) - __(Alex Lynch)__ Publicize FaultResponse and provide static hooks in HoneyBee struct for response management.
 * [3ff2723](../../commit/3ff2723) - __(Alex Lynch)__ Standardize positioning of @discardableResult.

#### v2.0.3
 * [fcebb83](../../commit/fcebb83) - __(Alex Lynch)__ Mark as v2.0.3 (documentation bump)

#### v2.0.1
 * [a9b3119](../../commit/a9b3119) - __(Alex Lynch)__ Mark as v2.0.1
 * [673b06f](../../commit/673b06f) - __(Alex Lynch)__ Expand documentation around block performer.

#### v2.0
 * [7092836](../../commit/7092836) - __(Alex Lynch)__ Mark as v2.0.
 * [b2187e2](../../commit/b2187e2) - __(Alex Lynch)__ Rename parameter "withLimit" to "limit".
 * [7eaa13d](../../commit/7eaa13d) - __(Alex Lynch)__ Rename ProcessLink to Link

#### v1.11.2
 * [2b0a203](../../commit/2b0a203) - __(Alex Lynch)__ Mark as v1.11.2
 * [aeaf7b0](../../commit/aeaf7b0) - __(Alex Lynch)__ Expand documentation.

#### v1.11.1
 * [31241e3](../../commit/31241e3) - __(Alex Lynch)__ Mark as v1.11.1 (documentation release).

#### v1.11
 * [2ec8982](../../commit/2ec8982) - __(Alex Lynch)__ Mark as v1.11
 * [f39323a](../../commit/f39323a) - __(Alex Lynch)__ Implement parallel reduce.

#### v1.10
 * [8a60f3d](../../commit/8a60f3d) - __(Alex Lynch)__ Mark as v1.10.0
 * [d14c4e4](../../commit/d14c4e4) - __(Alex Lynch)__ Add documentation fo left and right join, and reduce.
 * [7d3ecbf](../../commit/7d3ecbf) - __(Alex Lynch)__ Implement linear `reduce` behavior. Add thread sanitizer to test target. Fix some threading issues.
 * [c8c9019](../../commit/c8c9019) - __(Alex Lynch)__ Mark as v1.9.4. (documentation version).
 * [564aba9](../../commit/564aba9) - __(Alex Lynch)__ Mark as v1.9.3. (documentation release)
 * [f8f26cf](../../commit/f8f26cf) - __(Alex Lynch)__ Implement join-left and join-right operators.

#### v1.9.2
 * [f40413c](../../commit/f40413c) - __(Alex Lynch)__ Mark as v1.9.2
 * [3c15566](../../commit/3c15566) - __(Alex Lynch)__ Fix finally-before-retry bug.

#### v1.9.1
 * [cae6d66](../../commit/cae6d66) - __(Alex Lynch)__ Mark as v1.9.1
 * [05b284f](../../commit/05b284f) - __(Alex Lynch)__ Expose FailureRate feature in `each`

#### v1.9
 * [dd3d4a9](../../commit/dd3d4a9) - __(Alex Lynch)__ Marking as v1.9
 * [d27c21d](../../commit/d27c21d) - __(Alex Lynch)__ Implement retry feature.
 * [4139c3b](../../commit/4139c3b) - __(Alex Lynch)__ Clean up multi-path test semantics with AtomicInt

#### v1.8
 * [9292a65](../../commit/9292a65) - __(Alex Lynch)__ Mark as v1.8
 * [df18f7e](../../commit/df18f7e) - __(Alex Lynch)__ Restore typed finally blocks!!

#### v1.7.3
 * [6561158](../../commit/6561158) - __(Alex Lynch)__ Quick fix for cocoa pods. v1.7.3

#### v1.7.2
 * [164978d](../../commit/164978d) - __(Alex Lynch)__ Mark as v1.7.2.
 * [8870f8a](../../commit/8870f8a) - __(Alex Lynch)__ Fix bug causing joins to fail. Fix bug causing finalizers to fail and run out of order. Improve logical assertions about concurrency.

#### v1.7.1
 * [88d61b4](../../commit/88d61b4) - __(Alex Lynch)__ Mark as v1.7.
 * [45570e3](../../commit/45570e3) - __(Alex Lynch)__ Simplify `map` error counting.
 * [a1c7077](../../commit/a1c7077) - __(Alex Lynch)__ Links can create sub-links until they are deallocated. Redesign `optionally` with simpler semantics.
 * [4a51e50](../../commit/4a51e50) - __(Alex Lynch)__ Amend commit with project file changes.
 * [81d7417](../../commit/81d7417) - __(Alex Lynch)__ Make space for lib sources.

#### v1.6
 * [b25cbe6](../../commit/b25cbe6) - __(Alex Lynch)__ Include podspec version bump.
 * [d1ebfea](../../commit/d1ebfea) - __(Alex Lynch)__ Marking as v1.6
 * [32fc00c](../../commit/32fc00c) - __(Alex Lynch)__ Verify error handling behavior when map and join are used together.
 * [1bcd478](../../commit/1bcd478) - __(Alex Lynch)__ Proper error handling for map and filter.
 * [2a59fd5](../../commit/2a59fd5) - __(Alex Lynch)__ Links downstream of a join receive ancestorFailed() when appropriate.
 * [c345d20](../../commit/c345d20) - __(Alex Lynch)__ Joins are now error resilient. (The non-failing path doesn't block forever.)
 * [ee807db](../../commit/ee807db) - __(Alex Lynch)__ Append project file changes.
 * [07745ee](../../commit/07745ee) - __(Alex Lynch)__ Reorganize test grouping error handling together.
 * [e6b0cb7](../../commit/e6b0cb7) - __(Alex Lynch)__ Redefine `each` and `filter` in terms of `map`. Introduce `branch` with return link.
 * [00973ad](../../commit/00973ad) - __(Alex Lynch)__ Introduce parallel limit to each, map and filter.
 * [1498fb8](../../commit/1498fb8) - __(Alex Lynch)__ Reorganize testing code for faster compilations.
 * [a940af6](../../commit/a940af6) - __(Alex Lynch)__ Use proper compilation condition for KeyPath form.

#### v1.4.5
 * [c21396f](../../commit/c21396f) - __(Alex Lynch)__ Mark as v1.4.5
 * [87f8ddf](../../commit/87f8ddf) - __(Alex Lynch)__ Remove unnecessary escaping attributes from define blocks.

#### v1.4.4
 * [80fc24c](../../commit/80fc24c) - __(Alex Lynch)__ Mark as v1.4.4
 * [1aedfc9](../../commit/1aedfc9) - __(Alex Lynch)__ Remove poorly conceived execute success parameter and simplify.
 * [a7cd9ad](../../commit/a7cd9ad) - __(Alex Lynch)__ Don't try to compile KeyPath form for less than swift 4.0

#### v1.4.3
 * [c1a8a06](../../commit/c1a8a06) - __(Alex Lynch)__ Mark as v1.4.3
 * [321be79](../../commit/321be79) - __(Alex Lynch)__ More safely enter dispatch group to prevent early notification.
 * [554e7c7](../../commit/554e7c7) - __(Alex Lynch)__ Restore `each(withLimit:)`  form.

#### v1.4.2
 * [ddcf97f](../../commit/ddcf97f) - __(Alex Lynch)__ Mark as v1.4.2.
 * [66307d9](../../commit/66307d9) - __(Alex Lynch)__ Implement KeyPath support.

#### v1.4.1
 * [783161b](../../commit/783161b) - __(Alex Lynch)__ Marking as v1.4.1
 * [751fdac](../../commit/751fdac) - __(Alex Lynch)__ Extend bind support to throwing functions.
 * [b573fa9](../../commit/b573fa9) - __(Alex Lynch)__ Marking as version 1.4 (swift 4 compatible)
 * [5b2a07a](../../commit/5b2a07a) - __(Alex Lynch)__ Swift 4 support + much better code coverage.

#### v1.0.2
 * [7217eed](../../commit/7217eed) - __(Alex Lynch)__ Marking as v1.0.2.
 * [ece3302](../../commit/ece3302) - __(Alex Lynch)__ Improve resilience of `limit` for proper semaphore handing during errors.
 * [ebb6460](../../commit/ebb6460) - __(Alex Lynch)__ Marking as v1.0.1
 * [5a63069](../../commit/5a63069) - __(Alex Lynch)__ Suppress multiple callback for errors as well as successes. Remove references cycles caused by self-capture.
 * [1467b3c](../../commit/1467b3c) - __(Alex Lynch)__ Marking as v1.0 (yay!)
 * [9f19a24](../../commit/9f19a24) - __(Alex Lynch)__ Rename `fork` branch. Implement operator syntax for `conjoin`.
 * [2a4c846](../../commit/2a4c846) - __(Alex Lynch)__ Replace 'cntx' var names with more expressive, localized names.
 * [382db42](../../commit/382db42) - __(Alex Lynch)__ Implement 'tunnel' behavior.
 * [aa12000](../../commit/aa12000) - __(Alex Lynch)__ Rename 'value' to 'insert'. Implement 'drop'. Remove 'splice'
 * [0533360](../../commit/0533360) - __(Alex Lynch)__ Mark v0.10.1
 * [d3d2f91](../../commit/d3d2f91) - __(Alex Lynch)__ Marking as v0.10.0
 * [60fd8d6](../../commit/60fd8d6) - __(Alex Lynch)__ Convert map and filter to subchains.
 * [d848d28](../../commit/d848d28) - __(Alex Lynch)__ Marking as v0.9.1
 * [b032bea](../../commit/b032bea) - __(Alex Lynch)__ Add @escaping attribute where it was missing.
 * [9022d8f](../../commit/9022d8f) - __(Alex Lynch)__ Marking as v0.9.0
 * [25b6a20](../../commit/25b6a20) - __(Alex Lynch)__ Update tests to provide better code coverage.
 * [6271966](../../commit/6271966) - __(Alex Lynch)__ Update documentation.
 * [284893a](../../commit/284893a) - __(Alex Lynch)__ Redefine the root function as a FailableResult form. This is the most complex form. Handling it as the root function permits handling FailableResultProtocol in a single chain.
 * [21a9355](../../commit/21a9355) - __(Alex Lynch)__ Remove unnecessary overlap between ProcessLinks. Simplify!!!
 * [0bb4f72](../../commit/0bb4f72) - __(Alex Lynch)__ Marking as v0.8.2
 * [6210ad7](../../commit/6210ad7) - __(Alex Lynch)__ Implement functionDescription self-documentation for more helpful internalPath content in ErrorContext.
 * [6a13144](../../commit/6a13144) - __(Alex Lynch)__ Mark as v0.8.1
 * [0df9403](../../commit/0df9403) - __(Alex Lynch)__ Fix bug in ErrorContext file and line reporting.
 * [9915d96](../../commit/9915d96) - __(Alex Lynch)__ Mark as v0.8.0
 * [7c79805](../../commit/7c79805) - __(Alex Lynch)__ Implement support for swift style asynchronous errors with FailableResultProtocol.
 * [472c79a](../../commit/472c79a) - __(Alex Lynch)__ Implement functionFile, functionLine and internalPath properties of ErrorContext.
 * [5230b58](../../commit/5230b58) - __(Alex Lynch)__ Introduce ErrorContext, refactor and document.
 * [363c53e](../../commit/363c53e) - __(Alex Lynch)__ Mark as v0.7.1
 * [e9ea602](../../commit/e9ea602) - __(Alex Lynch)__ Correct fault in Tests around setBlockPerformer. Fix underlying bug.
 * [f22cde4](../../commit/f22cde4) - __(Alex Lynch)__ Marking as v0.7.0
 * [337fce4](../../commit/337fce4) - __(Alex Lynch)__ Abstract execution queue to support NSManagedObjectContexts.
 * [eeafe79](../../commit/eeafe79) - __(Alex Lynch)__ Remove unneeded dual-queue concept.
 * [76ada43](../../commit/76ada43) - __(Alex Lynch)__ Document project and mark as v0.6.2
 * [82ad53b](../../commit/82ad53b) - __(Alex Lynch)__ Mark as v0.6.1.
 * [900136a](../../commit/900136a) - __(Alex Lynch)__ Implement `setQueue`.
 * [f4dac4d](../../commit/f4dac4d) - __(Alex Lynch)__ Mark v0.6.0
 * [7ceefa9](../../commit/7ceefa9) - __(Alex Lynch)__ Remove potentially hazardous noError method from RootLink. Rename errorHandler to setError.
 * [86e99b7](../../commit/86e99b7) - __(Alex Lynch)__ Mark v0.5.0
 * [3977a54](../../commit/3977a54) - __(Alex Lynch)__ Simplify error handling expression in HoneyBee process definitions. Remove redundentant chain forms.

#### v0.4.1
 * [92071b5](../../commit/92071b5) - __(Alex Lynch)__ v0.4.1
 * [2d89ef0](../../commit/2d89ef0) - __(Alex Lynch)__ Correct post-limit behavior to not be within semaphore.

#### v0.4.0
 * [2b01f3c](../../commit/2b01f3c) - __(Alex Lynch)__ Mark as v0.4.0
 * [334a79b](../../commit/334a79b) - __(Alex Lynch)__ Slightly reorganize project.
 * [d6b2ac0](../../commit/d6b2ac0) - __(Alex Lynch)__ Remove operator syntax. The number of behaviors is growing and some take parameters. Operator syntax is no longer supportable.
 * [a828f4a](../../commit/a828f4a) - __(Alex Lynch)__ Implement `finally` and `limit` behaviors.
 * [8270a0d](../../commit/8270a0d) - __(Alex Lynch)__ Pass in failing object to error handler.
 * [e74aff9](../../commit/e74aff9) - __(Alex Lynch)__ Implement PathDescribing on JoinPoint
 * [09d74e7](../../commit/09d74e7) - __(Alex Lynch)__ Begin implementation of PathDescribing protocol for debugging and state keeping purposes. Add protection against multiple callbacks by client.
 * [c4518ad](../../commit/c4518ad) - __(Alex Lynch)__ `each` behavior forwards sequence as result.
 * [c58f68b](../../commit/c58f68b) - __(Alex Lynch)__ Delay evaluation of stored values in failableResultWrapper

#### v0.2.0
 * [fa269ce](../../commit/fa269ce) - __(Alex Lynch)__ 2.0
 * [3842e27](../../commit/3842e27) - __(Alex Lynch)__ More generated forms of chain and splice. Generated bind and bind operator.
 * [20060ac](../../commit/20060ac) - __(Alex Lynch)__ Remove (now) unnecessary dummy testing application. Just test.
 * [b61f62f](../../commit/b61f62f) - __(Alex Lynch)__ Version 0.1.8, open sourced.
 * [d13227e](../../commit/d13227e) - __(Alex Lynch)__ Remove unused variable.
 * [f4ff73c](../../commit/f4ff73c) - __(Alex Lynch)__ Execute root `function` on the provided queue. Adapt for threading difference.
 * [3febc61](../../commit/3febc61) - __(Alex Lynch)__ Release 0.1.5 built with swiftc 3.1. Suppress appending swiftc version number to build number until cocoa pods can handle it.
 * [68716d0](../../commit/68716d0) - __(Alex Lynch)__ Include swiftc version in build number.
 * [d066089](../../commit/d066089) - __(Alex Lynch)__ Generate chain forms to permit meta analysis.
 * [d73ec18](../../commit/d73ec18) - __(Alex Lynch)__ Publish 0.1.4
 * [3f971a3](../../commit/3f971a3) - __(Alex Lynch)__ Revert depreciations and add initial support for void forms of ‘chain’
 * [5d2b663](../../commit/5d2b663) - __(Alex Lynch)__ Add build and deploy script.
 * [c793d55](../../commit/c793d55) - __(Alex Lynch)__ Deprecate less-functionally oriented `value` and `start(with:)` behaviors.
 * [46603d6](../../commit/46603d6) - __(Alex Lynch)__ Move CommonCrypto framework source to separate project.
 * [ba118cb](../../commit/ba118cb) - __(Alex Lynch)__ Make framework a universal binary.
 * [0c2a2a8](../../commit/0c2a2a8) - __(Alex Lynch)__ Implement build number scrip.
 * [3af29ba](../../commit/3af29ba) - __(Alex Lynch)__ More functional description of `testEachWithRateLimiter`
 * [a6f8184](../../commit/a6f8184) - __(Alex Lynch)__ Implement rate limiter concept and support in `each` behavior.
 * [6b18038](../../commit/6b18038) - __(Alex Lynch)__ Make FailableResult internal.
 * [3ba8778](../../commit/3ba8778) - __(Alex Lynch)__ Make JoinPoint internal.
 * [42d23b7](../../commit/42d23b7) - __(Alex Lynch)__ Implement operator syntax for `chain,` `conjoin,` `value,` and `optionally`
 * [c7d3dcd](../../commit/c7d3dcd) - __(Alex Lynch)__ Privatize `joinPoint`
 * [8fc0a61](../../commit/8fc0a61) - __(Alex Lynch)__ Remove `splice` behavior and simplify `conjoin`
 * [2d9a7d4](../../commit/2d9a7d4) - __(Alex Lynch)__ Implement async signatures for map and filter.
 * [f75927f](../../commit/f75927f) - __(Alex Lynch)__ Implement `filter` behavior.
 * [869b152](../../commit/869b152) - __(Alex Lynch)__ `map` behavior passes queue to asyncMap .
 * [c9fc358](../../commit/c9fc358) - __(Alex Lynch)__ Test multi-parameter functions.
 * [33246f7](../../commit/33246f7) - __(Alex Lynch)__ Build test for ‘each’ behavior. Correct each behavior. Implement new secondary forms of ‘chain’
 * [1b275db](../../commit/1b275db) - __(Alex Lynch)__ Refactor tests around license protection.
 * [36b498f](../../commit/36b498f) - __(Alex Lynch)__ Added six optional callback forms. Miraculously resolve “chain2 abmbiguiuty problem”
 * [d9c295e](../../commit/d9c295e) - __(Alex Lynch)__ Reorganize access control and reduce ProcessLink clutter.
 * [cd13e26](../../commit/cd13e26) - __(Alex Lynch)__ Namespace the starting functions in a struct.
 * [9c589ff](../../commit/9c589ff) - __(Alex Lynch)__ Correct functional programming terminology.
 * [d2e9e65](../../commit/d2e9e65) - __(Alex Lynch)__ Commit CommonCrypto scheme.
 * [1306cdc](../../commit/1306cdc) - __(Alex Lynch)__ Implement access control strategy.
 * [c78f8bd](../../commit/c78f8bd) - __(Aaron Lynch)__ First round of Aaronchanges
 * [ffad587](../../commit/ffad587) - __(Alex Lynch)__ Add value checking to unit tests.
 * [00307b2](../../commit/00307b2) - __(Alex Lynch)__ Restructure project around testing and framework targets.
 * [db54c03](../../commit/db54c03) - __(Alex Lynch)__ Implement `each` behavior.
 * [136be94](../../commit/136be94) - __(Alex Lynch)__ Correct spelling error.
 * [22ad3de](../../commit/22ad3de) - __(Alex Lynch)__ Improve call site semantics and implement `optionally` behavior.
 * [bf49804](../../commit/bf49804) - __(Alex Lynch)__ Remove the unexpressive end() method and mark methods which return ProcessLink as @discardableResult
 * [5104523](../../commit/5104523) - __(Alex Lynch)__ Provide new secondary form of chain (the 3rd). Plus disambiguation alias.
 * [5607230](../../commit/5607230) - __(Alex Lynch)__ Ensure error handler is called in execution queue.
 * [3f2884e](../../commit/3f2884e) - __(Alex Lynch)__ Implement new secondary chaining form (the second).
 * [52dd27a](../../commit/52dd27a) - __(Alex Lynch)__ Define value behavior.
 * [6c47a35](../../commit/6c47a35) - __(Alex Lynch)__ Support execution queue selection in primary behaviors.
 * [b386625](../../commit/b386625) - __(Alex Lynch)__ Implement first of secondary forms.
 * [b959849](../../commit/b959849) - __(Alex Lynch)__ Organize methods around primary forms.
 * [a448c71](../../commit/a448c71) - __(Alex Lynch)__ Create iOS framework target.
 * [d222f21](../../commit/d222f21) - __(Alex Lynch)__ Publicize classes and methods for use in external module. Introduce splice method.
 * [5421b87](../../commit/5421b87) - __(Alex Lynch)__ Implement join.
 * [89211a6](../../commit/89211a6) - __(Alex Lynch)__ Implement checked error handling.
 * [37171a5](../../commit/37171a5) - __(Alex Lynch)__ Rename function to better clarify it’s meaning.
 * [8c96b13](../../commit/8c96b13) - __(Alex Lynch)__ Implement map instruction.
 * [549384a](../../commit/549384a) - __(Alex Lynch)__ Update method names for greater declarative clarity.
 * [e93ff6e](../../commit/e93ff6e) - __(Alex Lynch)__ Initial implementation of parallel syntax.
 * [218a839](../../commit/218a839) - __(Alex Lynch)__ Implement support for asynchronous methods.
 * [b0e3366](../../commit/b0e3366) - __(Alex Lynch)__ Cleaner syntax for process definitions.
 * [a37346d](../../commit/a37346d) - __(Alex Lynch)__ Proof of concept.
 * [4795c9f](../../commit/4795c9f) - __(Alex Lynch)__ Initial Commit
