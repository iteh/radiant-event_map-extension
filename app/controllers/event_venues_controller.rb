# We inherit from EventsController to share subsetting functionality
# All we do here is organise that information by venue.

class EventVenuesController < EventsController
  helper_method :venues, :events_at_venue, :slug_for_venue
  radiant_layout { Radiant::Config['event_map.layout'] }
  
  def index
    respond_to do |format|
      format.html { }
      format.js {
        render :layout => false
      }
      format.json {
        render :json => venue_events.to_json
      }
    end
  end
  
  # event_finder is defined in EventsController

  def events
    @events ||= all_events
  end
  
  def venues
    @venues ||= events.map(&:event_venue).compact.uniq
  end
  
  # events are stashed in venue buckets to avoid returning to the database
  
  def events_at_venue(venue)
    venue_events[venue.id]
  end
  
  def slug_for_venue(venue)
    if events = venue_events[venue.id]
      events.first.calendar.slug
    end
  end
    
protected

  def venue_events
    return @venue_events if @venue_events
    @venue_events = {}
    events.each do |e|
      if e.event_venue
        @venue_events[e.event_venue.id] ||= []
        @venue_events[e.event_venue.id].push(e)
      end
    end
    @venue_events
  end

end