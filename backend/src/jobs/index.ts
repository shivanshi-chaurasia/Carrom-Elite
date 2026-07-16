import { startMatchmakingWorker, getMatchmaker } from './matchmaking.worker';

export async function initializeJobQueues(): Promise<void> {
  await startMatchmakingWorker();
  getMatchmaker().start();
}

export async function shutdownJobQueues(): Promise<void> {
  getMatchmaker().stop();
}

export { getMatchmaker } from './matchmaking.worker';
