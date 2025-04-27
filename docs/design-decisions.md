# Database Design
You can view a database diagram that reflects the current database structure by visiting [this link](https://dbdiagram.io/d/sequra-65144e71ffbf5169f09d96d1).

NOTE:
- A PostgreSQL numeric type has been used to store amounts related with money. A scale of 2 has been used, as the financial system does not allow more than 2 decimals. A precision of 10 has been set for simplicity. Taking into account the generated stats, the precision should be increased, as some values are already reaching the maximum precision value.

- `disbursement_frequency` column at `merchants` table could be an enum at DB level but I’ve used a varchar type for simplicity and flexibility. I’ve used the Active Record model to handle the enum-like behavior.

- A `disbursed` boolean column could have been used at `orders` to make sure that orders are disbursed precisely once but we can rely on the relationship between orders and disbursements. Orders with a non null `disbursement_id` are already considered disbursed. Using a boolean column to track if orders have been disbursed or not could cause duplicity and data integrity issues.

# Business logic decisions
- Daily disbursements have been calculated based on the group orders for a given merchant paid during the previous day. Example: A daily disbursement created for a merchant at on Oct 27th at 07:00 includes all orders from Oct 26th 00:00:00 to Sep 26th 23:59:59. This logic applies similarly to weekly disbursements. Example: A weekly disbursement will be calculated for a merchant on Oct 28th, based on the orders for such merchant from Oct 21th 00:00:00 to Oct 27th 23:59:59.
By doing so, we ensure that the data on which we are based to compute disbursements is stable and race conditions or alterations are not expected for it.

- If a merchant live_on date is in the same month or after the date when the disbursement is being created, the minimum monthly fee will not be calculated
- I have decided to use Sidekiq to schedule the processing and creation of disbursements daily. The `Disbursements::ProcessorWorker` is scheduled to run daily at 07:00 AM UTC time. That's because the challenge description requires the disbursements calculation process to be completed, for all merchants, by 8:00 UTC daily. The time that'll take to run the worker cannot be predicted, as it depends on the workload for a specific day, so I have decided to run the worker one hour earlier to give it enough time to finish. This has been achieved through the configuration of `sidekiq-cron` gem at `config/schedule.yml` file. This configuration can be tested at rails console with:
```bash
docker exec -it rails rails c
irb(main):006:0> Sidekiq::Cron::Job.find('disbursement_processor')
=> 
#<Sidekiq::Cron::Job:0x00007f01836eab50
 @active_job=false,
 @active_job_queue_name_delimiter="",
 @active_job_queue_name_prefix="",
 @args=[],
 @cron="0 7 * * *",
 @date_as_argument=false,
 @description="",
 @errors=[],
 @fetch_missing_args=true,
 @klass="DisbursementProcessorWorker",
 @last_enqueue_time=nil,
 @message="{\"queue\":\"default\",\"class\":\"DisbursementProcessorWorker\",\"args\":[]}",
 @name="disbursement_processor",
 @parsed_cron=
  #<Fugit::Cron:0x00007f01836ea970
   @cron_s=nil,
   @day_and=nil,
   @hours=[7],
   @minutes=[0],
   @monthdays=nil,
   @months=nil,
   @original="0 7 * * *",
   @seconds=[0],
   @timezone=nil,
   @weekdays=nil,
   @zone=nil>,
 @queue="default",
 @queue_name_with_prefix="default",
 @status="enabled",
 @symbolize_args=false>
```

# Financial calculations
- Ruby `BigDecimal` objects have been used to perform financial calculations. `BigDecimal` are slower than `Float` objects, but provide higher precision and control over the number of decimals to use in calculations. `Float` objects are typically used in Ruby to represent decimals but, since they use binary floating-point representation, `Float` objects inherently have rounding errors due to the inability to represent certain decimal values precisely. Example:
```ruby
# With floats
f = 1.1
v = 0.0
1000.times do
v += f
end
v # 1100.0000000000086

# With big decimals
f = BigDecimal(1.1, 2)
v = BigDecimal(0)
1000.times do
v += f
end
v
# => 0.11e4
v.to_s('F')
# => "1100.0"
```

# Improvements
- Indexes could be added on some columns. Example: the `reference` column on `disbursements` should be indexed, if disbursements are expected to be queried by their reference usually.
- Error handling has been ignored. The rake tasks, services, methods implementations and tests have been focused on the happy path. Example: the rake tasks to import orders and merchants from the CSV files assume that the CSV file exists in hardcoded locations.
- As stated in the challenge description, the minimum monthly fee calculations have not been substracted from disbursements. A TODO comment has been added to mark where this fee should be used.
