# Ugh

- We cant use Intent Services as this would mean serial queuing of task

- We will use a service. Services run on the main thread :/ so we need threads

- Threads are a pita to manage so lets use a ThreadPoolExecutor, we can then have simple download
  code (maybe as async tasks) to do the actual downloading

- Using a Service gives us a mechanism to communicate with activity that results
  in an event. This is essential so we can drive uno actions from it and arent poll based.

  Saying that.. We do have runOnUIThread, so we could just use that & the ThreadPoolExecutor and fuck the rest

- Use a handler rather than a runOnUIThread, in case the activity isnt there

- There is sample here: https://developer.android.com/training/multiple-threads/create-threadpool.html#ThreadPool
  let's just use that and hack it into shape


haha fuck this (and fuck that sample is ugly)

https://github.com/tonyofrancis/Fetch?utm_source=android-arsenal.com&utm_medium=referral&utm_campaign=5196
