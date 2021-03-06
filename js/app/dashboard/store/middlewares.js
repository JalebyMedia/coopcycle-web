import {
  addCreatedTask,
  setGeolocation,
  updateTask,
  setOffline
} from './actions'
import moment from 'moment'

// If the user has not been seen for 5min, it is considered offline
const OFFLINE_TIMEOUT = (5 * 60 * 1000)

// Check every 30s
const OFFLINE_TIMEOUT_INTERVAL = (30 * 1000)

let socket

function checkLastSeen(dispatch, getState) {

  getState().positions.forEach(position => {
    const diff = moment().diff(position.lastSeen)
    if (diff > OFFLINE_TIMEOUT) {
      dispatch(setOffline(position.username))
    }
  })

  setTimeout(() => {
    checkLastSeen(dispatch, getState)
  }, OFFLINE_TIMEOUT_INTERVAL)
}

export const socketIO = ({ dispatch, getState }) => {

  if (!socket) {

    socket = io(`//${window.location.hostname}`, {
      path: '/tracking/socket.io',
      extraHeaders: {
        Authorization: `Bearer ${getState().jwt}`
      }
    })

    socket.on('task:done', data => dispatch(updateTask(data.task)))
    socket.on('task:failed', data => dispatch(updateTask(data.task)))
    socket.on('task:cancelled', data => dispatch(updateTask(data.task)))
    socket.on('task:created', data => dispatch(addCreatedTask(data.task)))

    socket.on('tracking', data => dispatch(setGeolocation(data.user, data.coords)))

    setTimeout(() => {
      checkLastSeen(dispatch, getState)
    }, OFFLINE_TIMEOUT_INTERVAL)

  }

  return next => action => {

    return next(action)
  }
}
