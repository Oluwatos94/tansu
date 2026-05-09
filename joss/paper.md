---
title: "Tansu: bringing open-source communities on-chain"
tags:
  - Stellar
  - Stellar smart contract
  - software supply chain security
  - decentralized governance
  - anonymous voting
  - NFT
authors:
  - name: Pamphile T. Roy
    affiliation: "1"
    corresponding: true
    orcid: 0000-0001-9816-1416
affiliations:
  - index: 1
    name: Consulting Manao GmbH, Austria
date: 9 May 2026
bibliography: paper.bib
---

# Summary

Tansu (<https://tansu.dev>) is software that gives open-source projects a public, tamper-evident on-chain record of
their releases and governance decisions. Built on Stellar through Stellar smart
contracts [@tansu_repo; @stellar_soroban], it complements Git and existing code-hosting platforms by
anchoring project state, commit references, and governance outcomes on chain. Anyone can then verify which release a
project endorses, who is allowed to do so, and how the decision was reached.

The contracts cover project registration through Soroban Domains, commit tracking, IPFS-anchored proposals, public and
anonymous voting, and role-weighted membership. The Stellar Community Fund (SCF) deployment binds
voting weights to Neural Quorum Governance (NQG) scores and represents members as soulbound SEP-50 NFTs; a public
member explorer reads the role and NQG traits attached to each token [@scf_member_explorer].

# Statement of need

Open-source software now underpins much of the world's digital infrastructure, yet its release and governance still
rely on centralised accounts, hosting platforms, and continuous-integration systems. A compromised maintainer, a
tampered release pipeline, or an opaque governance decision can propagate to downstream consumers before anyone
notices. Frameworks such as SLSA [@slsa] address the build and provenance side of this risk, but the question of who
is allowed to declare a release trustworthy still rests with the project itself.

Tansu addresses that question with *code finality*: a maintainer-defined trust level (for example *released*,
*security-reviewed*, or *revoked*) attached to a specific commit hash by an on-chain governance event. The contracts
supply the mechanism — proposals, weighted voting, and outcome contracts that a successful vote invokes — and each
project assembles those primitives into a trust workflow suited to its threat model. The goal is
not to put source code on chain, but to make a project's trust state explicit and verifiable.

# State of the field

Adjacent parts of this problem are well covered. TUF, in-toto, and Sigstore harden update security, build provenance,
and artifact signing [@tuf; @in_toto; @sigstore]. Snapshot and on-chain governor frameworks support DAO proposals and
voting [@snapshot; @openzeppelin_governor]. These tools, however, keep software lineage and project governance in
separate silos: provenance frameworks rarely say who is allowed to declare a release trustworthy, and governance
frameworks rarely tie their outcomes to specific commit hashes.

Tansu was built to close that gap, asking whether project governance, release trust, membership weight, and executable
outcomes can share a single auditable state machine. They can: a vote in Tansu directly binds a governance outcome to a
commit hash and may invoke a downstream contract to act on it.

# Software design

Tansu is a set of Stellar smart contracts written in Rust, accompanied by a web client, documentation, and deployment
tooling. The code is released under the BSD 3-Clause License.

Only trust-critical state is anchored on chain. Source code, pull requests, and day-to-day collaboration remain on
conventional forges, while project registration, commit hashes, maintainer sets, proposals, and votes are stored or
verified through the contracts. This keeps the on-chain footprint small.

Governance supports both public and anonymous voting. In anonymous mode, each voter submits encrypted payloads
alongside BLS12-381 Pedersen-style commitments of the form `C = g·v + h·r`, where `v` encodes the choice and `r` is a
random seed [@pedersen]. At execution time the contract verifies that the aggregate tallies and
seeds match the on-chain commitments, releasing the outcome without ever publishing individual ballots. The scheme is
intentionally not trustless: a designated key holder can decrypt ballots and is responsible for submitting the tally.
Projects pick public or anonymous mode according to their governance model.

Voting weights are visible on chain. Tansu supports badge-based weights and, where configured, NQG-derived weights.
The SCF membership contract represents each member as a soulbound SEP-50 NFT carrying two governance traits: `role`,
set by the contract admin, and `nqg`, fetched live from the NQG contract [@scf_member_explorer].
The contract makes governance reputation auditable, but it is not a Sybil-resistance mechanism on its own; that
guarantee comes from the membership policy that decides who receives an NFT.

# Research impact statement

Tansu is deployed on Stellar mainnet [@stellar_expert_tansu]. The DAO and anonymous voting features were
built during the SCF Build tranches [@scf_rec_build].

The Stellar Community Fund Public Goods Award uses Tansu for its on-chain process: the award documentation specifies
Tansu-based proposal submission and NQG-weighted voting, and the dApp ships matching proposal templates together with
a configured SCF Governance project [@pg_award_overview; @pg_award_tansu_mods; @pg_award_proposer]. To the author's
knowledge this is the first use of anonymous on-chain voting on Stellar in a live public-goods funding process.

Tansu is also one of the most active projects in the Stellar Drips Wave, a programme that pays external contributors
for upstream maintenance work [@drips_wave_docs; @drips_wave_tansu].

# AI usage disclosure

No generative AI tools were used in the design or implementation of the Stellar smart contracts under `contracts/`. All
contract logic, cryptographic constructions, and security-sensitive code were written and reviewed by humans.

Generative AI assistance was used inside the Cursor IDE during 2025–2026, drawing on OpenAI GPT (including GPT-5.5)
and Anthropic Claude (including Claude Opus 4). The scope was limited to parts of the web client under `dapp/`,
copy-editing of project documentation under `website/`, and drafting and editing this manuscript. The author reviewed
every change, checked the cited sources against the repository, and remains responsible for the technical claims,
design decisions, licensing, and policy compliance of the software and this paper.

# Acknowledgements

Development of Tansu has been funded by the Stellar Community Fund through the Activation and Build
tracks [@scf_rec_activation; @scf_rec_build; @scf_rec_pg]. The author thanks the SCF community and the reviewers,
contributors, and maintainers across the Stellar ecosystem who have shaped Tansu and the surrounding tooling.

# References
