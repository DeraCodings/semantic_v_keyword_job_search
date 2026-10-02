/**
 * Targeted Google Dork search presets for discovering database, backend,
 * and data infrastructure job postings across major ATS job boards.
 */
export const DATABASE_SEARCH_PRESETS = {
  // PostgreSQL Administration & Engineering roles
  POSTGRESQL_JOBS: [
    '(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("PostgreSQL" OR "Postgres DBA" OR "PostgreSQL Engineer" OR "Database Reliability Engineer") -site:reddit.com -site:linkedin.com -site:tealhq.com',
  ],

  // Database Systems & Storage Infrastructure
  DATABASE_ENGINEER: [
    '(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("Database Engineer" OR "Storage Engineer" OR "Distributed Systems") -site:reddit.com -site:linkedin.com -site:tealhq.com',
  ],

  // Data Engineering & Analytics Infrastructure
  DATA_ENGINEER: [
    '(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("Data Engineer" OR "Analytics Infrastructure" OR "ETL Pipeline") -site:reddit.com -site:linkedin.com -site:tealhq.com',
  ],

  // Backend & Systems Development
  BACKEND_DEVELOPER: [
    '(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("Backend Engineer" OR "Senior Go Developer" OR "Python Backend Engineer" OR "Node.js Developer") -site:reddit.com -site:linkedin.com -site:tealhq.com',
  ],

  // Cloud & Site Reliability Engineering
  INFRASTRUCTURE_ENGINEER: [
    '(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("DevOps Engineer" OR "Site Reliability Engineer" OR "SRE" OR "Kubernetes Infrastructure") -site:reddit.com -site:linkedin.com -site:tealhq.com',
  ],

  // Frontend Engineering & Web Development
  FRONTEND_DEVELOPER: [
    '(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("Frontend Engineer" OR "React Developer" OR "Vue.js Developer" OR "Web Application Developer") -site:reddit.com -site:linkedin.com -site:tealhq.com',
  ],

  // Full-Stack Development & Software Engineering
  FULLSTACK_DEVELOPER: [
    '(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("Full-Stack Engineer" OR "Full-Stack Developer" OR "Software Engineer" OR "Software Developer") -site:reddit.com -site:linkedin.com -site:tealhq.com',
  ],
};
