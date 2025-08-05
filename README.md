# Decentralized Public Safety and Crime Prevention Network

A blockchain-based system for coordinating public safety efforts, crime prevention, and community policing through smart contracts on the Stacks blockchain.

## System Overview

This network consists of five interconnected smart contracts that work together to enhance public safety:

### 1. Community Policing Coordination (`community-policing.clar`)
- Facilitates secure communication between police departments and neighborhood watch groups
- Manages patrol schedules and coordination requests
- Tracks community engagement metrics
- Handles incident reporting and response coordination

### 2. Crime Pattern Analysis (`crime-analysis.clar`)
- Records and analyzes crime incidents to identify patterns
- Maintains hotspot mapping for optimal patrol route planning
- Tracks crime statistics and trends over time
- Provides data-driven insights for resource allocation

### 3. Evidence Chain of Custody (`evidence-custody.clar`)
- Maintains immutable records of physical evidence handling
- Tracks evidence transfers between departments and personnel
- Ensures integrity of evidence chain for legal proceedings
- Provides audit trails for all evidence interactions

### 4. Witness Protection Coordination (`witness-protection.clar`)
- Manages secure communication channels for protected witnesses
- Coordinates protection resource allocation
- Maintains anonymized witness status tracking
- Handles secure information sharing between agencies

### 5. Community Safety Resource Sharing (`safety-resources.clar`)
- Coordinates shared safety infrastructure (cameras, lighting, alarms)
- Manages resource availability and maintenance schedules
- Facilitates community investment in safety improvements
- Tracks resource utilization and effectiveness

## Key Features

- **Decentralized Governance**: Community-driven decision making for safety initiatives
- **Immutable Records**: Blockchain-based evidence and incident tracking
- **Privacy Protection**: Secure handling of sensitive information
- **Resource Optimization**: Data-driven allocation of safety resources
- **Community Engagement**: Direct participation in neighborhood safety

## Security Considerations

- All sensitive data is hashed before storage
- Access controls ensure only authorized personnel can modify records
- Privacy-preserving mechanisms protect witness and victim information
- Audit trails provide transparency while maintaining security

## Getting Started

1. Deploy contracts to Stacks testnet/mainnet
2. Initialize each contract with appropriate admin principals
3. Configure access permissions for police departments and community groups
4. Begin recording incidents and coordinating safety efforts

## Contract Interactions

Each contract operates independently but can be used together for comprehensive public safety management:

- Police departments register incidents in crime-analysis
- Evidence from incidents is tracked in evidence-custody
- Community groups coordinate through community-policing
- Witnesses are protected via witness-protection
- Safety resources are managed through safety-resources

## Testing

Run the test suite with:
\`\`\`bash
npm test
\`\`\`

Tests cover all contract functions, error conditions, and integration scenarios.
