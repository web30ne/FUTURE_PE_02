// (example) minimal pattern to skip git push when SKIP_PUSH is set
const child_process = require('child_process');
const skipPush = process.env.SKIP_PUSH === 'true' || process.argv.includes('--no-push');

function run(cmd) {
  return child_process.execSync(cmd, { stdio: 'inherit' });
}

// ... your generation logic that writes files ...

// Only commit/push if not skipped
if (!skipPush) {
  run('git add README.md'); // adjust paths as needed
  run('git commit -m "chore: update README [skip ci]" || true');
  run('git push origin HEAD');
} else {
  console.log('SKIP_PUSH=true — skipping git add/commit/push in generator');
}
